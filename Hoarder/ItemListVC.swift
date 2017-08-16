//
//  ItemListVC.swift
//  Hoarder
//
//  Created by Huan Cung on 7/27/17.
//  Copyright © 2017 Huan Cung. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class ItemListVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate,ParentViewController {
    @IBOutlet weak var itemTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchSegmentedControl: UISegmentedControl!
    
    var collectionName: String!
    var collectionUID: String!
    var itemList = [ItemType]()
    var filteredItemList = [ItemType]()
    var inSearchMode = false
    var willReloadData: Bool = false
    var parentVC: ParentViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        searchBar.enablesReturnKeyAutomatically = false
        itemTableView.delegate = self
        itemTableView.dataSource = self
        itemTableView.backgroundColor = UIColor.clear
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
        itemTableView.deselectRow(at: indexPath, animated: true)
        let item = getItem(index: indexPath.row)
        performSegue(withIdentifier: "editItemSegue", sender: item)
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
        let itemDataRef = Database.database().reference().child("items").child(collectionUID)
        BusyModal.startBusyModalAndHideNav(targetViewController: self)
        itemDataRef.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            if let itemSets = snapshot.value as? NSDictionary {
                self.resetSearch()
                self.itemList.removeAll()
                for (_, item) in itemSets {
                    let itemDict = item as! NSDictionary
                    
                    let ownerID = itemDict["ownerID"] as! String
                    let collectionID = itemDict["collectionID"] as! String
                    let itemID = itemDict["itemID"] as! String
                    let name = itemDict["name"] as! String
                    let description = itemDict["description"] as! String
                    let imageID = itemDict["imageID"] as! String
                    let imageURL = itemDict["imageURL"] as! String
                    let dateAdded = itemDict["dateAdded"] as! Double
                    let dateAddedString = DateTimeUtilities.formatTimeInterval(timeInterval: dateAdded)
                    
                    let item = ItemType(ownerID: ownerID, collectionID: collectionID, itemID: itemID, itemName: name, description: description, imageID: imageID, imageURL: imageURL, dateAdded: dateAdded, dateAddedString: dateAddedString)
                    item.downloadImage()
                    self.itemList.append(item)
                }
                self.itemList = self.itemList.sorted(by: {$0.itemName < $1.itemName})
                self.updateItemCount()
                self.itemTableView.reloadData()
            }
            BusyModal.stopBusyModalAndShowNav(targetViewController: self)
        })
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
        
        let refItems = Database.database().reference().child("items").child(item.collectionID).child(item.itemID)
        BusyModal.startBusyModalAndHideNav(targetViewController: self)
        // Delete item in database
        refItems.setValue(nil)
        
        // Delete saved image
        if !item.imageID.isEmpty {
            let storageRef = Storage.storage().reference().child("ItemImages").child(item.collectionID).child("\(item.imageID).png")
            storageRef.delete { (error) in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
        BusyModal.stopBusyModalAndShowNav(targetViewController: self)
        
        if inSearchMode {
            self.filteredItemList.remove(at: itemIndex)
        } else {
            self.itemList.remove(at: itemIndex)
        }
        
        populateItemCellData()
    }
    
    private func updateItemCount() {
        let refCollectionInfo = Database.database().reference().child("collections")
        
        if let uid = Auth.auth().currentUser?.uid {
            let newCollection = ["itemCount": itemList.count] as [String : Any]
            
            refCollectionInfo.child(uid).child(collectionUID).updateChildValues(newCollection)
        }
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
