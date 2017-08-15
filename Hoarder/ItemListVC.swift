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
    
    var collectionUID: String!
    var itemList = [ItemType]()
    var willReloadData: Bool = false
    var parentVC: ParentViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        itemTableView.delegate = self
        itemTableView.dataSource = self
        itemTableView.backgroundColor = UIColor.clear
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
        return itemList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
        itemTableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "editItemSegue", sender: itemList[indexPath.row])
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
        let item = itemList[indexPath.row]
        cell.updateUI(item: item)
    }
    
    private func populateItemCellData() {
        let itemDataRef = Database.database().reference().child("items").child(collectionUID)
        BusyModal.startBusyModalAndHideNav(targetViewController: self)
        itemDataRef.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            if let itemSets = snapshot.value as? NSDictionary {
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
                self.updateItemCount()
                self.itemTableView.reloadData()
            }
            BusyModal.stopBusyModalAndShowNav(targetViewController: self)
        })
    }
    
    private func deleteItem(itemIndex: Int) {
        let item = itemList[itemIndex]
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
        self.itemList.remove(at: itemIndex)
    }
    
    private func updateItemCount() {
        let refCollectionInfo = Database.database().reference().child("collections")
        
        if let uid = Auth.auth().currentUser?.uid {
            let newCollection = ["itemCount": itemList.count] as [String : Any]
            
            refCollectionInfo.child(uid).child(collectionUID).updateChildValues(newCollection)
        }
    }
    
    @IBAction func addEditItemPressed(_ sender: Any) {
        performSegue(withIdentifier: "addItemSegue", sender: nil)
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
