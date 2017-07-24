//
//  NewCollectionVC.swift
//  Hoarder
//
//  Created by Huan Cung on 7/21/17.
//  Copyright © 2017 Huan Cung. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class NewCollectionVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var collectionNameText: UITextField!
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var descriptionText: UITextView!

    let collectionCategories = ["Auto Supplies", "Clothing", "Toys", "Craft Supplies", "Furniture", "Household Goods", "Electronics", "Art", "Animals", "General Stuff", "Books", "Accessories", "Supplies", "Tools", "Toiletries", "Memorabilia", "Movies", "Antiques", "Hobby", "Other", "Garden", "Outdoors", "Food", "Wine and Spirits", "Baby and Kids", "Sports"]
    
    var sortedCollectionCategories: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryPicker.delegate = self
        sortedCollectionCategories = collectionCategories.sorted()
        // Do any additional setup after loading the view.
    }

    @IBAction func createCollectionPressed(_ sender: Any) {
        if let collectionName = collectionNameText.text, !collectionName.isEmpty {
            var description = ""
            
            if let desc = descriptionText.text, !desc.isEmpty {
                description = desc
            }
            
            let category = sortedCollectionCategories[categoryPicker.selectedRow(inComponent: 0)]
            
            AlertUtil.message(title: "New Collection Created!", message: "Now you can start adding items to this collection!", targetViewController: self)
            
            saveCollectionInfo(collectionName: collectionName, category: category, description: description)
        } else {
            AlertUtil.alert(message: "Please add a collection name!", targetViewController: self)
        }
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return sortedCollectionCategories[row].capitalized
    }
    
    // Rows
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sortedCollectionCategories.count
    }
    
    // Columns
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label: UILabel
        if let view = view as? UILabel { label = view }
        else { label = UILabel() }
        
        label.textColor = UIColor.darkGray
        label.textAlignment = .center
        label.font = UIFont(name: "Helvetica Neue", size: 17.0)
        label.adjustsFontSizeToFitWidth = false
        label.minimumScaleFactor = 0.5
        label.text = getTextForPicker(atRow: row) // implemented elsewhere
        
        return label
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    /**
     Returns the text associated with the index of selected from the category picker.
     - parameters
        - atRow: Index of the selection in the picker.
    */
    private func getTextForPicker(atRow: Int) -> String {
        return sortedCollectionCategories[atRow]
    }
    
    /**
     Saves the collection info.
     - parameters
        - collectionName: Name of the collection.
        - category: Category of that the collection.
        - description: Description of the collection.
    */
    private func saveCollectionInfo(collectionName: String, category: String, description: String) {
        let refCollectionInfo = Database.database().reference().child("collections")
        
        
        
        if let uid = Auth.auth().currentUser?.uid {
            let key = refCollectionInfo.child("collections").childByAutoId().key
            let newCollection = ["ownerUid" : uid, "name": collectionName, "category": category ,"description": description, "collectionID": key, "itemCount": 0, "creationDate": DateTimeUtilities.getTimestamp()] as [String : Any]
            
            refCollectionInfo.child(uid).child(key).setValue(newCollection)
        }
    }
}
