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

class CollectionListVC: UIViewController, UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var collectionTableView: UITableView!
    var collectionList = [CollectionType]()

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionTableView.delegate = self
        collectionTableView.dataSource = self
        collectionTableView.backgroundColor = UIColor.clear
        populateCollectionData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        populateCollectionData()
    }
    
    @IBAction func addCollectionPressed(_ sender: Any) {
        performSegue(withIdentifier: "NewCollectionSegue", sender: nil)
    }
    @IBAction func settingsButtonPressed(_ sender: Any) {
        print("set")
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
        cell.updateUI(collection: collection)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return collectionList.count
        return collectionList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if let obj = controller.fetchedObjects, obj.count > 0 {
//            let item = obj[indexPath.row]
//            
//            performSegue(withIdentifier: "ItemDetailsSegue", sender: item)
//            
//        }
        
        print("selected")
    }
    
    private func populateCollectionData() {
        let uid = Auth.auth().currentUser?.uid
        let collectionRef = Database.database().reference().child("collections").child(uid!)
        
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
                    let creationDateString = DateTimeUtilities.formatTimeInterval(timeInterval: myCollection["creationDate"] as! Double)
                   
                    let collectionObj = CollectionType(collectionName: name, category: category, description: description, collectionID: collectionID, itemCount: itemCount, ownerID: ownerID, creationDateString: creationDateString, creationDate: creationDate)
                    self.collectionList.append(collectionObj)
                }
                self.collectionList = self.collectionList.sorted(by: {$0.dateCreated > $1.dateCreated})
                self.collectionTableView.reloadData()
            }
        })
    }
    
    
    @IBAction func setupButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "editCollectionSegue", sender: nil)
    }
}
