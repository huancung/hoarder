//
//  CollectionListVC.swift
//  Hoarder
//
//  Created by Huan Cung on 7/18/17.
//  Copyright © 2017 Huan Cung. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class CollectionListVC: UIViewController, UITableViewDelegate, UITableViewDataSource, ParentViewController {
    @IBOutlet weak var collectionTableView: UITableView!
    @IBOutlet weak var sortSegController: UISegmentedControl!
    
    var blurEffectView: UIVisualEffectView?
    var collectionList = [CollectionType]()
    var willReloadData: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.regular)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        collectionTableView.delegate = self
        collectionTableView.dataSource = self
        collectionTableView.backgroundColor = UIColor.clear
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
        performSegue(withIdentifier: "ItemListSegue", sender: collectionList[indexPath.row].collectionID)
    }
    
    private func populateCollectionData() {
        let uid = Auth.auth().currentUser?.uid
        let collectionRef = Database.database().reference().child("collections").child(uid!)
        startBusyModal()
        collectionRef.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            if let collectionSet = snapshot.value as? NSDictionary {
                self.collectionList.removeAll()
                
                for (_, collection) in collectionSet {
                    let myCollection = collection as! NSDictionary
                    let name = myCollection["name"] as! String
                    let category = myCollection["category"] as! String
                    let description = myCollection["description"] as! String
                    let collectionID = myCollection["collectionID"] as! String
                    let ownerID = myCollection["ownerUid"] as! String
                    let itemCount = myCollection["itemCount"] as! Int
                    let creationDate = myCollection["creationDate"] as! Double
                    let isFavorite = myCollection["isFavorite"] as! String
                    let creationDateString = DateTimeUtilities.formatTimeInterval(timeInterval: myCollection["creationDate"] as! Double)
                   
                    let collectionObj = CollectionType(collectionName: name, category: category, description: description, collectionID: collectionID, itemCount: itemCount, ownerID: ownerID, creationDateString: creationDateString, creationDate: creationDate, isFavorite: isFavorite)
                    self.collectionList.append(collectionObj)
                }
                
                
                self.setSortOrder(sortBy: self.sortSegController.selectedSegmentIndex)
                self.stopBusyModal()
                self.collectionTableView.reloadData()
            }
        })
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
                if let collectionUID = sender as? String {
                    destination.parentVC = self
                    destination.collectionUID = collectionUID
                }
            }
        }
    }
    
    /**
     Removes a busy modal from the view if there is one being displayed.
     */
    private func stopBusyModal() {
        if blurEffectView != nil {
            blurEffectView?.removeFromSuperview()
        }
    }
    
    /**
     Adds a busy modal overlay that blocks out controls while app is busy.
     */
    private func startBusyModal() {
        if let modal = blurEffectView {
            
            modal.frame = view.bounds
            modal.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
            actInd.center = modal.center
            actInd.hidesWhenStopped = true
            actInd.activityIndicatorViewStyle = .whiteLarge
            modal.addSubview(actInd)
            actInd.startAnimating()
            
            view.addSubview(modal)
        }
    }

}
