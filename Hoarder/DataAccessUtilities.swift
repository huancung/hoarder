//
//  DataAccessUtilities.swift
//  Hoarder
//
//  Created by Huan Cung on 8/22/17.
//  Copyright © 2017 Huan Cung. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage
import FirebaseAuth
import FirebaseDatabase

public class DataAccessUtilities {
    static let sharedInstance = DataAccessUtilities()
    
    static func getCollectionsList(handler: @escaping (_ collectionsList: [CollectionType]) ->Void) {
        let uid = Auth.auth().currentUser?.uid
        let collectionRef = Database.database().reference().child("collections").child(uid!)
        collectionRef.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            var collectionList = [CollectionType]()
            if let collectionSet = snapshot.value as? NSDictionary {
                
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
                    collectionList.append(collectionObj)
                }
            }
            handler(collectionList)
        })
    }
    
    /**
     Updates the collection info.
     - parameters:
        - collectionName: Name of the collection.
        - category: Category of that the collection.
        - description: Description of the collection.
        - collectionID: Id for the collection being updated.
        - creationDate: Creation date as a unix timestamp.
        - isFavorite: true or false string to mark if collection is favorite.
     */
    static func updateCollectionInfo(collectionName: String, category: String, description: String, collectionID: String, creationDate: Double, isFavorite: String) {
        let refCollectionInfo = Database.database().reference().child("collections")
        if let uid = Auth.auth().currentUser?.uid {
            let newCollection = ["ownerUid" : uid, "name": collectionName, "category": category ,"description": description, "collectionID": collectionID, "creationDate": creationDate, "isFavorite": isFavorite] as [String : Any]
            
            refCollectionInfo.child(uid).child(collectionID).updateChildValues(newCollection)
        }
    }
    
    /**
     Saves the collection info.
     - parameters
     - collectionName: Name of the collection.
     - category: Category of that the collection.
     - description: Description of the collection.
     */
    static func saveCollectionInfo(collectionName: String, category: String, description: String) {
        let refCollectionInfo = Database.database().reference().child("collections")
        
        if let uid = Auth.auth().currentUser?.uid {
            let key = refCollectionInfo.child("collections").childByAutoId().key
            let newCollection = ["ownerUid" : uid, "name": collectionName, "category": category ,"description": description, "collectionID": key, "itemCount": 0, "creationDate": DateTimeUtilities.getTimestamp(), "isFavorite": "false"] as [String : Any]
            
            refCollectionInfo.child(uid).child(key).setValue(newCollection)
        }
    }
    
    static func deleteCollection(collectionID: String) {
        let refCollectionInfo = Database.database().reference().child("collections")

        if let uid = Auth.auth().currentUser?.uid {
            refCollectionInfo.child(uid).child(collectionID).setValue(nil)
        }
    }
    
    static func deleteItems(collectionID: String) {
        let refItems = Database.database().reference().child("items").child(collectionID)

        // Getting list of imageIDs
        refItems.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            if let itemSets = snapshot.value as? NSDictionary {
                for (_, item) in itemSets {
                    let itemDict = item as! NSDictionary
                    let imageID = itemDict["imageID"] as! String
                    
                    // Delete saved image
                    let storageRef = Storage.storage().reference().child("ItemImages").child(collectionID).child("\(imageID).png")
                    storageRef.delete { (error) in
                        if let error = error {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
            
            // Delete item in database
            refItems.setValue(nil)
        })
    }
    
    static func deleteItemImageFromStorage(imageID: String, collectionID: String) {
        let imageRef = Storage.storage().reference().child("ItemImages").child(collectionID).child("\(imageID).png")
        imageRef.delete { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    static func deleteItemInfo(collectionID: String, itemID: String) {
        let refItems = Database.database().reference().child("items").child(collectionID).child(itemID)
        refItems.setValue(nil)
    }
    
    static func saveItemInfo(itemName: String, description: String, imageID: String, imageURL: String, collectionID: String, itemID: String?) {
        if let uid = Auth.auth().currentUser?.uid {
            let refItemInfo = Database.database().reference().child("items").child(collectionID)
            var key: String!
            
            if itemID == nil {
                key = refItemInfo.childByAutoId().key
            }
            
            let newItem = ["ownerID": uid, "collectionID" : collectionID, "name": itemName ,"description": description, "itemID": key, "imageID": imageID, "imageURL": imageURL, "dateAdded": DateTimeUtilities.getTimestamp()] as [String : Any]
            
            refItemInfo.child(key).setValue(newItem)
        }
    }
    
    static func saveImage(imageData: Data, collectionID: String, handler: @escaping (_ success: Bool, _ imageURL: String, _ imageKey: String) -> Void) {
        let imageKey = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("ItemImages").child(collectionID).child("\(imageKey).png")
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        
        storageRef.putData(imageData, metadata: metadata).observe(.success, handler: { (snapshot) in
            var imageURL = ""
            if let url = snapshot.metadata?.downloadURL()?.absoluteString {
                imageURL = url
            }
            handler(true, imageURL, imageKey)
        })
    }
    
    static func getItemsList(collectionID: String, handler: @escaping (_ itemList: [ItemType]) ->Void) {
        let itemDataRef = Database.database().reference().child("items").child(collectionID)
        itemDataRef.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            var itemList = [ItemType]()
            if let itemSets = snapshot.value as? NSDictionary {
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
                    itemList.append(item)
                }
            }
            handler(itemList)
        })
    }
    
    static func updateItemCount(collectionID: String, count: Int) {
        let refCollectionInfo = Database.database().reference().child("collections")
        
        if let uid = Auth.auth().currentUser?.uid {
            let newCollection = ["itemCount": count] as [String : Any]
            
            refCollectionInfo.child(uid).child(collectionID).updateChildValues(newCollection)
        }
    }
}
