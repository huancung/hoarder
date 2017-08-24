//
//  ItemListVC.swift
//  Hoarder
//
//  Created by Huan Cung on 7/27/17.
//  Copyright © 2017 Huan Cung. All rights reserved.
//

import UIKit

class ItemListVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIPickerViewDataSource, UIPickerViewDelegate, ParentViewController {
    @IBOutlet weak var itemTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchSegmentedControl: UISegmentedControl!
    @IBOutlet var actionButton: UIBarButtonItem!
    @IBOutlet var addItemButton: UIBarButtonItem!
    var doneButtonItem: UIBarButtonItem!
    
    var collectionName: String!
    var collectionUID: String!
    var collectionsList: [CollectionType]!
    var itemList = [ItemType]()
    var filteredItemList = [ItemType]()
    var inSearchMode = false
    var willReloadData: Bool = false
    var parentVC: ParentViewController?
    
    var testdata = ["opt 1","opt 2","opt 3","opt 4","opt 5"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        searchBar.enablesReturnKeyAutomatically = false
        itemTableView.delegate = self
        itemTableView.dataSource = self
        itemTableView.backgroundColor = UIColor.clear
        itemTableView.allowsMultipleSelectionDuringEditing = true
        navigationItem.title = collectionName
        if let topItem = self.navigationController?.navigationBar.topItem {
            let button = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            
            topItem.backBarButtonItem = button
        }
        
        populateItemCellData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if willReloadData {
            willReloadData = false
            populateItemCellData()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as? ItemCell {
            configureCell(cell: cell, indexPath: indexPath)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if inSearchMode {
            return filteredItemList.count
        }
        return itemList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
        
        if !itemTableView.isEditing {
            itemTableView.deselectRow(at: indexPath, animated: true)
            let item = getItem(index: indexPath.row)
            performSegue(withIdentifier: "editItemSegue", sender: item)
        } else {
            print(itemTableView.indexPathsForSelectedRows ?? "")
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            print("delete \(indexPath.row)")
            self.deleteItem(itemIndex: indexPath.row)
            self.itemTableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        return [delete]
    }
    
    func configureCell(cell: ItemCell, indexPath: IndexPath) {
        let item = getItem(index: indexPath.row)
        
        cell.updateUI(item: item)
    }
    
    func getItem(index: Int) -> ItemType {
        var item: ItemType!
        
        if inSearchMode {
            item = filteredItemList[index]
        } else {
            item = itemList[index]
        }
        
        return item
    }
    
    private func populateItemCellData() {
        BusyModal.startBusyModalAndHideNav(targetViewController: self)
        DataAccessUtilities.getItemsList(collectionID: collectionUID) { (returnItemList) in
            print("here1")
            self.itemList = returnItemList.sorted(by: {$0.itemName < $1.itemName})
            print("here2")
            self.itemTableView.reloadData()
            print("here3")
            DataAccessUtilities.updateItemCount(collectionID: self.collectionUID, count: self.itemList.count)
            print("here5")
            BusyModal.stopBusyModalAndShowNav(targetViewController: self)
        }
    }
    
    private func resetSearch() {
        inSearchMode = false
        searchBar.text = ""
    }
    
    private func deleteItem(itemIndex: Int) {
        var item: ItemType!
        
        if inSearchMode {
            item = filteredItemList[itemIndex]
        } else {
            item = itemList[itemIndex]
        }
        
        BusyModal.startBusyModalAndHideNav(targetViewController: self)
        // Delete item in database
        DataAccessUtilities.deleteItemInfo(collectionID: collectionUID, itemID: item.itemID)
        
        // Delete saved image
        if !item.imageID.isEmpty {
            DataAccessUtilities.deleteItemImageFromStorage(imageID: item.imageID, collectionID: collectionUID)
        }
        
        BusyModal.stopBusyModalAndShowNav(targetViewController: self)
        
        if inSearchMode {
            self.filteredItemList.remove(at: itemIndex)
        } else {
            self.itemList.remove(at: itemIndex)
        }
        
        populateItemCellData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text  == "" {
            resetSearch()
            view.endEditing(true)
            itemTableView.reloadData()
        } else {
            inSearchMode = true
            
            let searchText = searchBar.text!.lowercased()
            
            if searchSegmentedControl.selectedSegmentIndex == 0 {
                filteredItemList = itemList.filter({$0.itemName.lowercased().range(of: searchText) != nil})
            } else {
                filteredItemList = itemList.filter({$0.description.lowercased().range(of: searchText) != nil})
            }
            
            
//            if filteredItemList.isEmpty {
//                notFoundLbl.isHidden = false
//            } else {
//                notFoundLbl.isHidden = true
//            }
            
            itemTableView.reloadData()
        }
    }
    
    @IBAction func addEditItemPressed(_ sender: Any) {
        performSegue(withIdentifier: "addItemSegue", sender: nil)
    }
    
    @IBAction func searchSegmentChanged(_ sender: Any) {
        if inSearchMode {
            let searchText = searchBar.text!.lowercased()
            
            if searchSegmentedControl.selectedSegmentIndex == 0 {
                filteredItemList = itemList.filter({$0.itemName.lowercased().range(of: searchText) != nil})
            } else {
                filteredItemList = itemList.filter({$0.description.lowercased().range(of: searchText) != nil})
            }
            
            itemTableView.reloadData()
        }
    }
    
    func doneButtonPressed() {
        if let selectedItems = itemTableView.indexPathsForSelectedRows, selectedItems.count > 0 {
            let optionMenu = UIAlertController(title: "Choose an Action", message: nil, preferredStyle: .actionSheet)
            
            let copyAction = UIAlertAction(title: "Copy Items to...", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                //do something
                self.collectionSelect()
            })
            
            let moveAction = UIAlertAction(title: "Move Items to...", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                //do something
                self.collectionSelect()
            })
            
            let deleteAction = UIAlertAction(title: "Delete Selected Items", style: .destructive, handler: {
                (alert: UIAlertAction!) -> Void in
                //do something
                self.endEditMode()
            })
            
            optionMenu.addAction(copyAction)
            optionMenu.addAction(moveAction)
            optionMenu.addAction(deleteAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                (alert: UIAlertAction!) -> Void in
                //do something
                self.endEditMode()
            })

            optionMenu.addAction(cancelAction)
            
            self.present(optionMenu, animated: true, completion: nil)
        } else {
            endEditMode()
        }
    }
    
    private func collectionSelect() {
        if collectionsList.count == 1 {
            AlertUtil.message(title: "Not Gonna Happen", message: "You have to create another hoard to do this action!", targetViewController: self)
        }
        
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 250,height: 200)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 250, height: 200))
        pickerView.delegate = self
        pickerView.dataSource = self
        vc.view.addSubview(pickerView)
        
        let selectCollectionAlert = UIAlertController(title: "Choose a collection", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        selectCollectionAlert.setValue(vc, forKey: "contentViewController")
        selectCollectionAlert.addAction(UIAlertAction(title: "Done", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            //do something
            self.endEditMode()
        }))
        
        selectCollectionAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            self.endEditMode()
        }))
        self.present(selectCollectionAlert, animated: true)
    }
    
    private func endEditMode() {
        itemTableView.setEditing(false, animated: true)
        navigationItem.setRightBarButton(nil, animated: true)
        navigationItem.setRightBarButtonItems([addItemButton, actionButton], animated: true)
        navigationItem.setHidesBackButton(false, animated: true)
    }
    
    @IBAction func actionButtonPressed(_ sender: Any) {
        if !itemTableView.isEditing {
            itemTableView.setEditing(true, animated: true)
            navigationItem.setHidesBackButton(true, animated: true)
            navigationItem.setRightBarButton(nil, animated: true)
            navigationItem.setRightBarButton(doneButtonItem, animated: true)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return collectionsList[row].collectionName.capitalized
    }
    
    // Rows
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return collectionsList.count
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
        label.font = UIFont(name: "Helvetica Neue", size: 25.0)
        label.adjustsFontSizeToFitWidth = false
        label.minimumScaleFactor = 0.5
        label.text = collectionsList[row].collectionName
        
        return label
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addItemSegue" {
            if let destination = segue.destination as? ItemVC {
                destination.parentVC = self
                destination.collectionUID = collectionUID
            }
        } else if segue.identifier == "editItemSegue" {
            if let destination = segue.destination as? ItemVC {
                destination.parentVC = self
                destination.collectionUID = collectionUID
                destination.loadedItem = sender as? ItemType
            }
        }
    }

}
