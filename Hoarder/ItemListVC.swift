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
    
    enum ItemActionOption: String {
        case copy, move
    }
    
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
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
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
            self.itemList = returnItemList.sorted(by: {$0.itemName < $1.itemName})
            self.itemTableView.reloadData()
            DataAccessUtilities.updateItemCount(collectionID: self.collectionUID)
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
                self.collectionSelect(itemAction: ItemActionOption.copy)
            })
            
            let moveAction = UIAlertAction(title: "Move Items to...", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.collectionSelect(itemAction: ItemActionOption.move)
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
    
    private func collectionSelect(itemAction: ItemActionOption) {
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
            
            let toCollectionID = self.collectionsList[pickerView.selectedRow(inComponent: 0)].collectionID
            
            // We will do nothing if we are moving or copying to the same collection
            if toCollectionID != self.collectionUID {
                let selectedIndexPaths = self.itemTableView.indexPathsForSelectedRows
                // Copy action or move action
                if selectedIndexPaths != nil && itemAction == ItemActionOption.copy {
                    BusyModal.startBusyModal(targetViewController: self)
                    // Copy items
                    for indexPath in selectedIndexPaths! {
                        var itemToCopy: ItemType
                        if self.inSearchMode {
                            itemToCopy = self.filteredItemList[indexPath.row]
                        } else {
                            itemToCopy = self.itemList[indexPath.row]
                        }
                        
                        DataAccessUtilities.copyItem(item: itemToCopy, toCollectionID: toCollectionID)
                    }
                    BusyModal.stopBusyModal()
                    AlertUtil.message(title: "\(selectedIndexPaths?.count ?? 0) Items Copied!", message: "", targetViewController: self)
                } else if selectedIndexPaths != nil && itemAction == ItemActionOption.move{
                    BusyModal.startBusyModal(targetViewController: self)
                    // Move Items
                    
                    for indexPath in selectedIndexPaths! {
                        var itemToMove: ItemType
                        if self.inSearchMode {
                            itemToMove = self.filteredItemList[indexPath.row]
                        } else {
                            itemToMove = self.itemList[indexPath.row]
                        }
                        
                        DataAccessUtilities.copyItem(item: itemToMove, toCollectionID: toCollectionID)
                        
                        DataAccessUtilities.deleteItemInfo(collectionID: itemToMove.collectionID, itemID: itemToMove.itemID)
                        
                        if itemToMove.imageID != "" {
                            DataAccessUtilities.deleteItemImageFromStorage(imageID: itemToMove.imageID, collectionID: itemToMove.collectionID)
                        }
                    }
                    BusyModal.stopBusyModal()
                    
                    AlertUtil.message(title: "\(selectedIndexPaths?.count ?? 0) Items Moved!", message: "", targetViewController: self)
                    self.populateItemCellData()
                } else {
                    BusyModal.startBusyModal(targetViewController: self)
                    // Move Items
                    
                    for indexPath in selectedIndexPaths! {
                        var itemToMove: ItemType
                        if self.inSearchMode {
                            itemToMove = self.filteredItemList[indexPath.row]
                        } else {
                            itemToMove = self.itemList[indexPath.row]
                        }
                        
                        DataAccessUtilities.deleteItemInfo(collectionID: itemToMove.collectionID, itemID: itemToMove.itemID)
                        
                        if itemToMove.imageID != "" {
                            DataAccessUtilities.deleteItemImageFromStorage(imageID: itemToMove.imageID, collectionID: itemToMove.collectionID)
                        }
                    }
                    BusyModal.stopBusyModal()
                    
                    AlertUtil.message(title: "\(selectedIndexPaths?.count ?? 0) Items Deleted!", message: "", targetViewController: self)
                    self.populateItemCellData()
                }
                
                DataAccessUtilities.updateItemCount(collectionID: toCollectionID)
                self.endEditMode()
            } else {
                AlertUtil.alert(message: "Pick a different collection!", targetViewController: self)
            }
            
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
            doneButtonItem.isEnabled = true
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
