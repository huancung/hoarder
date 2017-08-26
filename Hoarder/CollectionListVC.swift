//
//  CollectionListVC.swift
//  Hoarder
//
//  Created by Huan Cung on 7/18/17.
//  Copyright © 2017 Huan Cung. All rights reserved.
//

import UIKit

class CollectionListVC: UIViewController, UITableViewDelegate, UITableViewDataSource, ParentViewController {
    @IBOutlet weak var collectionTableView: UITableView!
    @IBOutlet weak var sortSegController: UISegmentedControl!

    var collectionList = [CollectionType]()
    var willReloadData: Bool = false
    var willSetCountUpdateObservers = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionTableView.delegate = self
        collectionTableView.dataSource = self
        collectionTableView.backgroundColor = UIColor.clear
        populateCollectionData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        populateCollectionData()
    }
    
    @IBAction func signOutPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        if willReloadData {
            willReloadData = false
            populateCollectionData()
        }
    }
    
    @IBAction func segControlValueChanged(_ sender: Any) {
        setSortOrder(sortBy: self.sortSegController.selectedSegmentIndex)
        collectionTableView.reloadData()
    }
    
    @IBAction func addCollectionPressed(_ sender: Any) {
        performSegue(withIdentifier: "NewCollectionSegue", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "collectionCell", for: indexPath) as? CollectionCell {
            configureCell(cell: cell, indexPath: indexPath)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func registerItemCountListeners() {
        for collection in collectionList {
            print("Register \(collection.collectionID)")
            DataAccessUtilities.updateItemCount(collectionID: collection.collectionID)
        }
    }
    
    func resetItemDataChangeOservers() {
        willSetCountUpdateObservers = true
        for collection in collectionList {
            print("Unregister \(collection.collectionID)")
            DataAccessUtilities.removeAllObservers(collectionID: collection.collectionID)
        }
    }
    
    func configureCell(cell: CollectionCell, indexPath: IndexPath) {
        let collection = collectionList[indexPath.row]
        cell.setEditIndex(index: indexPath.row)
        cell.updateUI(collection: collection)
        cell.setFavorite(isFavorite: collection.isFavorite == "true")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return collectionList.count
        return collectionList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        collectionTableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "ItemListSegue", sender: collectionList[indexPath.row])
    }
    
    private func populateCollectionData() {
        BusyModal.startBusyModal(targetViewController: self)
        DataAccessUtilities.getCollectionsList { (returnedCollectionsList) in
            self.collectionList = returnedCollectionsList
            self.setSortOrder(sortBy: self.sortSegController.selectedSegmentIndex)
            BusyModal.stopBusyModal()
            self.collectionTableView.reloadData()
            
            // On initial view load of this view we register all the count update listeners
            // it will automatically update the counts for the collections if items are added/removed.
            if self.willSetCountUpdateObservers {
                self.willSetCountUpdateObservers = false
                self.registerItemCountListeners()
            }
        }
    }
    
    private func populateAndInitialize() {
        BusyModal.startBusyModal(targetViewController: self)
        DataAccessUtilities.getCollectionsList { (returnedCollectionsList) in
            self.collectionList = returnedCollectionsList
            self.setSortOrder(sortBy: self.sortSegController.selectedSegmentIndex)
            BusyModal.stopBusyModal()
            self.collectionTableView.reloadData()
        }
    }
    
    private func setSortOrder(sortBy: Int) {
        switch sortBy {
            case 0:
                collectionList = collectionList.sorted(by: { (c1, c2) -> Bool in
                    if c1.isFavorite == "true" && c2.isFavorite == "false" {
                        return true //this will return true: c1 is priority, c2 is not
                    }
                    if c1.isFavorite == "false" && c2.isFavorite == "true" {
                        return false //this will return false: c2 is priority, c1 is not
                    }
                    if c1.isFavorite == c2.isFavorite {
                        return c1.collectionName < c2.collectionName // do alpha instead
                    }
                    return false
                })
            case 1:
                collectionList = collectionList.sorted(by: {$1.collectionName > $0.collectionName})
            default:
                collectionList = collectionList.sorted(by: {$0.dateCreated > $1.dateCreated})
        }
    }
    
    @IBAction func setupButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "editCollectionSegue", sender: collectionList[sender.tag])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editCollectionSegue" {
            if let destination = segue.destination as? EditCollectionVC {
                if let collectionobj = sender as? CollectionType {
                    destination.parentVC = self
                    destination.collectionObj = collectionobj
                }
            }
        } else if segue.identifier == "NewCollectionSegue" {
            if let destination = segue.destination as? NewCollectionVC {
                destination.parentVC = self
            }
        } else if segue.identifier == "ItemListSegue" {
            if let destination = segue.destination as? ItemListVC {
                if let collection = sender as? CollectionType {
                    destination.parentVC = self
                    destination.collectionName = collection.collectionName
                    destination.collectionUID = collection.collectionID
                    destination.collectionsList = collectionList.sorted(by: {$1.collectionName > $0.collectionName})
                }
            }
        }
    }
}
