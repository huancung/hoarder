//
//  ItemVC.swift
//  Hoarder
//
//  Created by Huan Cung on 7/31/17.
//  Copyright © 2017 Huan Cung. All rights reserved.
//

import UIKit

class ItemVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet var cancelButton: UIBarButtonItem!
    
    var isImageSet = false
    var imagePicker: UIImagePickerController!
    var collectionUID: String!
    var loadedItem: ItemType?
    var parentVC: ParentViewController?
    var editMode: Bool = false
    var imageRemoved: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        navigationItem.setHidesBackButton(true, animated: true)
            
        // Edit item mode
        if loadedItem != nil {
            navigationItem.title = "Item Details"
            editMode = true
            cancelButton.title = "Done"
            
            // load image
            if loadedItem?.itemImage != nil {
                itemImage.image = loadedItem?.itemImage
            }
            
            // load item info
            nameText.text = loadedItem?.itemName
            descriptionText.text = loadedItem?.description
        }
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
            self.present(self.imagePicker, animated: true, completion: nil)
        })
        
        let chooseFile = UIAlertAction(title: "Choose Photo", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        })
        
        optionMenu.addAction(takePhotoAction)
        optionMenu.addAction(chooseFile)
        if editMode || isImageSet {
            let viewImage = UIAlertAction(title: "View Image", style: .default) { (alert) in
                self.performSegue(withIdentifier: "imageZoomSegue", sender: nil)
            }
            
            optionMenu.addAction(viewImage)
            
            let removeImage = UIAlertAction(title: "Remove Image", style: .default) { (alert) in
                self.isImageSet = false
                self.itemImage.image = UIImage(named: "imagePlaceholder")
                self.imageRemoved = true;
            }
            
            optionMenu.addAction(removeImage)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        parentVC?.willReloadData = false
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        if let name = nameText.text, !name.isEmpty {
            var description = ""
            
            if let desc = descriptionText.text, !desc.isEmpty {
                description = desc
            }
            
            BusyModal.startBusyModalAndHideNav(targetViewController: self)
            if isImageSet {
                saveItemWithImage(itemName: name, description: description)
            } else {
                var imageID = ""
                var imageURL = ""
                if editMode {
                    if imageRemoved {
                        deleteSavedImage()
                    } else {
                        imageID = (loadedItem?.imageID)!
                        imageURL = (loadedItem?.imageURL)!
                    }
                }
                
                saveItemInfo(itemName: name, description: description, imageID: imageID, imageURL: imageURL)
            }
        } else {
            AlertUtil.alert(message: "Please add an item name!", targetViewController: self)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        
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
        isImageSet = true
    }
    
    private func saveItemWithImage(itemName: String, description: String) {
        if let image = itemImage.image {
            // 1/6 the image size
            let targetSize = CGSize(width: image.size.width/6, height: image.size.height/6)
            let resizedImage = resizeImage(image: image, targetSize: targetSize)
            let imageData = UIImagePNGRepresentation(resizedImage)!
            
            DataAccessUtilities.saveImage(imageData: imageData, collectionID: collectionUID, handler: { (success, imageURL, imageKey) in
                if success {
                    self.saveItemInfo(itemName: itemName, description: description, imageID: imageKey, imageURL: imageURL)
                
                    // Delete the old image if one exists
                    if self.editMode {
                        self.deleteSavedImage()
                    }
                }
            })
        }
    }
    
    private func deleteSavedImage() {
        if let oldImageID = loadedItem?.imageID {
            DataAccessUtilities.deleteItemImageFromStorage(imageID: oldImageID, collectionID: collectionUID)
        }
    }
    
    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    private func saveItemInfo(itemName: String, description: String, imageID: String, imageURL: String) {
        
        if editMode {
            DataAccessUtilities.saveItemInfo(itemName: itemName, description: description, imageID: imageID, imageURL: imageURL, collectionID: collectionUID, itemID: loadedItem?.itemID)
        } else {
            DataAccessUtilities.saveItemInfo(itemName: itemName, description: description, imageID: imageID, imageURL: imageURL, collectionID: collectionUID, itemID: nil)
        }
        
        BusyModal.stopBusyModalAndShowNav(targetViewController: self)
        self.parentVC?.willReloadData = true
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "imageZoomSegue" {
            let destination = segue.destination as? ImageZoomVC
            destination?.image = itemImage.image
        }
    }
}
