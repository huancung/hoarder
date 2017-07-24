//
//  EditCollectionVC.swift
//  Hoarder
//
//  Created by Huan Cung on 7/23/17.
//  Copyright © 2017 Huan Cung. All rights reserved.
//

import UIKit

class EditCollectionVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    @IBOutlet weak var collectionNameText: UITextField!
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var descriptionText: UITextView!
    
    let collectionCategories = ["Auto Supplies", "Clothing", "Toys", "Craft Supplies", "Furniture", "Household Goods", "Electronics", "Art", "Animals", "General Stuff", "Books", "Accessories", "Supplies", "Tools", "Toiletries", "Memorabilia", "Movies", "Antiques", "Hobby", "Other", "Garden", "Outdoors", "Food", "Wine and Spirits", "Baby and Kids", "Sports"]

    var sortedCollectionCategories: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryPicker.delegate = self
        sortedCollectionCategories = collectionCategories.sorted()
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

    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func trashButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Warning", message: "Your entire hoard will be trashed! Though a little house cleaning in your life is a good thing, are you sure you want to get rid of this hoard?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "NO!", style: .default) { (alert) in
        })
        alert.addAction(UIAlertAction(title: "YES", style: .default) { (alert) in
            // Delete the collection
        })
        self.present(alert, animated: true, completion: nil)
    }
    
}
