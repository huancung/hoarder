//
//  NewCollectionVC.swift
//  Hoarder
//
//  Created by Huan Cung on 7/21/17.
//  Copyright © 2017 Huan Cung. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class NewCollectionVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var collectionNameText: UITextField!
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var descriptionText: UITextView!

    let collectionCategories = ["Autos", "Clothing", "Toys", "Craft Supplies", "Furniture", "Household Goods", "Electronics", "Art", "Animals", "General Stuff", "Books", "Accessories", "Supplies", "Tools", "Toiletries"]
    
    var sortedCollectionCategories: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryPicker.delegate = self
        sortedCollectionCategories = collectionCategories.sorted()
        // Do any additional setup after loading the view.
    }

    @IBAction func createCollectionPressed(_ sender: Any) {
        if let collectionName = collectionNameText.text, !collectionName.isEmpty {
            // Save the entries
            // display alert
            AlertUtil.message(title: "New Collection Created!", message: "Now you can start adding items to this collection!", targetViewController: self)
            if let desc = descriptionText.text, !desc.isEmpty {
                let category = sortedCollectionCategories[categoryPicker.selectedRow(inComponent: 0)]
                saveCollectionInfo(collectionName: collectionName, category: category, description: desc)
            }
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
    
    func getTextForPicker(atRow: Int) -> String {
        return sortedCollectionCategories[atRow]
    }
    
    private func saveCollectionInfo(collectionName: String, category: String, description: String) {
        let refCollectionInfo = Database.database().reference().child("collections")
        
        if let uid = Auth.auth().currentUser?.uid {
            let key = refCollectionInfo.child("collections").childByAutoId().key
            let newCollection = ["ownerUid" : uid, "name": collectionName, "category": category ,"description": description]
            
            refCollectionInfo.child(uid).child(key).setValue(newCollection)
        }
    }
}
