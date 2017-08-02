//
//  ItemVC.swift
//  Hoarder
//
//  Created by Huan Cung on 7/31/17.
//  Copyright © 2017 Huan Cung. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ItemVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var descriptionText: UITextView!
    
    
    var imagePicker: UIImagePickerController!
    var collectionUID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        if collectionUID != nil {
            print(collectionUID)
        }
        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func doneButtonKBDismiss(_ sender: Any) {
        self.view.endEditing(true)
    }
    

    @IBAction func imageButtonPressed(_ sender: Any) {
        let optionMenu = UIAlertController(title: "Add Image", message: nil, preferredStyle: .actionSheet)
        
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.imagePicker.sourceType = .camera
            //self.imagePicker.allowsEditing = true

            self.present(self.imagePicker, animated: true, completion: nil)
            print("take photo")
        })
        
        let chooseFile = UIAlertAction(title: "Choose Photo", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.imagePicker.sourceType = .photoLibrary
            //self.imagePicker.allowsEditing = true
            
            self.present(self.imagePicker, animated: true, completion: nil)
            print("Choose file")
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        optionMenu.addAction(takePhotoAction)
        optionMenu.addAction(chooseFile)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        //var myImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        var image : UIImage!
        
        if let img = info[UIImagePickerControllerEditedImage] as? UIImage
        {
            image = img
            
        }
        else if let img = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            image = img
        }
        
        itemImage.image = image
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        if let name = nameText.text, !name.isEmpty {
            var description = ""
            
            if let desc = descriptionText.text, !desc.isEmpty {
                description = desc
            }
            
            if true {
                saveItemWithImage(itemName: name, description: description)
            } else {
                saveItemInfo(itemName: name, description: description, imageID: "", imageURL: "")
            }
            
            dismiss(animated: true, completion: nil)
        } else {
            AlertUtil.alert(message: "Please add an item name!", targetViewController: self)
        }
    }
    
    private func saveItemWithImage(itemName: String, description: String) {
        let imageKey = NSUUID().uuidString
        if let image = itemImage.image {
            let storageRef = Storage.storage().reference().child("ItemImages").child("\(imageKey).png")
            
            let imageData = UIImagePNGRepresentation(image)!
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/png"
            
            storageRef.putData(imageData, metadata: metadata).observe(.success, handler: { (snapshot) in
                var imageURL = ""
                if let url = snapshot.metadata?.downloadURL()?.absoluteString {
                    imageURL = url
                }
                self.saveItemInfo(itemName: itemName, description: description, imageID: imageKey, imageURL: imageURL)
            })
        }
        
    }
    
    private func saveItemInfo(itemName: String, description: String, imageID: String, imageURL: String) {
        let refCollectionInfo = Database.database().reference().child("Items")
        
        if let uid = Auth.auth().currentUser?.uid {
            let key = refCollectionInfo.childByAutoId().key
            let newItem = ["ownerID": uid, "collectionID" : collectionUID, "name": itemName ,"description": description, "itemID": key, "imageID": imageID, "imageURL": imageURL, "dateAdded": DateTimeUtilities.getTimestamp()] as [String : Any]
            
            refCollectionInfo.child(key).setValue(newItem)
        }
    }
}
