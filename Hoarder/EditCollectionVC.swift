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
    @IBOutlet weak var favoriteButton: UIButton!
    
    var parentVC: ParentViewController?
    var collectionObj: CollectionType!
    var unselectedAlpha = 0.65
    var selectedAlpha = 1.0
    var isFavorite = "false"
    
    let collectionCategories = ["Auto Supplies", "Clothing", "Toys", "Craft Supplies", "Furniture", "Household Goods", "Electronics", "Art", "Animals", "General Stuff", "Books", "Accessories", "Supplies", "Tools", "Toiletries", "Memorabilia", "Movies", "Antiques", "Hobby", "Other", "Garden", "Outdoors", "Food", "Wine and Spirits", "Baby and Kids", "Sports"]

    var sortedCollectionCategories: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryPicker.delegate = self
        sortedCollectionCategories = collectionCategories.sorted()
        navigationItem.setHidesBackButton(true, animated: true)
        
        if collectionObj != nil {
            loadData()
        }
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
    
    private func loadData() {
        collectionNameText.text = collectionObj?.collectionName
        descriptionText.text = collectionObj?.description
        setFavorite(favorite: collectionObj!.isFavorite)
        
        let category = collectionObj?.category
        var index = 0
        
        repeat{
            let s = sortedCollectionCategories[index]
            if s == category {
                categoryPicker.selectRow(index, inComponent: 0, animated: false)
                break
            }
            index += 1
        } while (index < sortedCollectionCategories.count)
    }
    
    private func setFavorite(favorite: String) {
        if "true" == favorite {
            favoriteButton.alpha = CGFloat(selectedAlpha)
            isFavorite = "true"
        } else {
            favoriteButton.alpha = CGFloat(unselectedAlpha)
            isFavorite = "false"
        }
    }

    @IBAction func saveButtonPressed(_ sender: Any) {
        if let collectionName = collectionNameText.text, !collectionName.isEmpty {
            var description = ""
            
            if let desc = descriptionText.text, !desc.isEmpty {
                description = desc
            }
            
            let category = sortedCollectionCategories[categoryPicker.selectedRow(inComponent: 0)]
            saveCollectionInfo(collectionName: collectionName, category: category, description: description)
        } else {
            AlertUtil.alert(message: "Please add a collection name!", targetViewController: self)
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        parentVC?.willReloadData = false
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func favoriteButtonPressed(_ sender: Any) {
        if isFavorite == "true" {
            setFavorite(favorite: "false")
        } else {
            setFavorite(favorite: "true")
        }
    }
    
    @IBAction func trashButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Warning", message: "Your entire hoard will be trashed! Though a little house cleaning in your life is a good thing, are you sure you want to get rid of this hoard?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "NO!", style: .default) { (alert) in
        })
        alert.addAction(UIAlertAction(title: "YES", style: .default) { (alert) in
            self.deleteCollection()
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    /**
     Saves the collection info.
     - parameters
     - collectionName: Name of the collection.
     - category: Category of that the collection.
     - description: Description of the collection.
     */
    private func saveCollectionInfo(collectionName: String, category: String, description: String) {
        BusyModal.startBusyModalAndHideNav(targetViewController: self)
        
        let collectionID = collectionObj.collectionID
        let creationDate =  collectionObj.dateCreated
        DataAccessUtilities.updateCollectionInfo(collectionName: collectionName, category: category, description: description, collectionID: collectionID, creationDate: creationDate, isFavorite: isFavorite)
        
        BusyModal.stopBusyModalAndShowNav(targetViewController: self)
        parentVC?.willReloadData = true
        self.navigationController?.popViewController(animated: true)
    }
    
    private func deleteCollection() {
        BusyModal.startBusyModalAndHideNav(targetViewController: self)
        let collectionID = collectionObj.collectionID
        DataAccessUtilities.deleteCollection(collectionID: collectionID)
        DataAccessUtilities.deleteItems(collectionID: collectionID)
        
        BusyModal.stopBusyModalAndShowNav(targetViewController: self)
        parentVC?.willReloadData = true
        self.navigationController?.popViewController(animated: true)
    }
}
