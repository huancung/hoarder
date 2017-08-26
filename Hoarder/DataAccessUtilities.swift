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
    static var itemCountHandles = [UInt]()
    
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
    static func saveCollectionInfo(collectionName: String, category: String, description: String) -> String {
        let refCollectionInfo = Database.database().reference().child("collections")
        var collectionID = ""
        if let uid = Auth.auth().currentUser?.uid {
            let key = refCollectionInfo.child("collections").childByAutoId().key
            let newCollection = ["ownerUid" : uid, "name": collectionName, "category": category ,"description": description, "collectionID": key, "itemCount": 0, "creationDate": DateTimeUtilities.getTimestamp(), "isFavorite": "false"] as [String : Any]
            
            refCollectionInfo.child(uid).child(key).setValue(newCollection)
            collectionID = key
        }
        
        return collectionID
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
            // Remove cached image
            deleteImageFromCache(imageID: imageID)
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
            } else {
                key = itemID
            }
            
            let newItem = ["ownerID": uid, "collectionID" : collectionID, "name": itemName ,"description": description, "itemID": key, "imageID": imageID, "imageURL": imageURL, "dateAdded": DateTimeUtilities.getTimestamp()] as [String : Any]
            
            refItemInfo.child(key).setValue(newItem)
        }
    }
    
    static func copyItem(item: ItemType, toCollectionID: String) {
        if item.collectionID != toCollectionID {
            if let image = item.itemImage {
                let imageData = UIImagePNGRepresentation(image)!
                
                self.saveImage(imageData: imageData, collectionID: toCollectionID, handler: { (success, imageURL, imageKey) in
                    if success {
                        saveItemInfo(itemName: item.itemName, description: item.description, imageID: imageKey, imageURL: imageURL, collectionID: toCollectionID, itemID: nil)
                    }
                })
            } else {
                saveItemInfo(itemName: item.itemName, description: item.description, imageID: "", imageURL: "", collectionID: toCollectionID, itemID: nil)
            }
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
    
    static func signIn(email: String, password:String, completion: @escaping (_ user: User?,_ error: Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: { (returnUser, returnError) in
            
            completion(returnUser, returnError)
        })
    }
    
    static func signOut() throws {
        try Auth.auth().signOut()
    }
    
    /**
     Save user's personal information.
     - parameters:
     - uid: Unique ID provided by the user account
     - firstName: User's first name
     - lastName: User's last name
     - email: User's email
     */
    static func savePersonalInfo(uid: String, firstName: String, lastName: String, email: String) {
        let refPersonalInfo = Database.database().reference().child("personalInfo")
        
        let newUser = ["uid" : uid, "firstName": firstName, "lastName": lastName, "email": email]
        
        refPersonalInfo.child(uid).setValue(newUser)
    }
    
    static func createNewAccount(email: String, password:String, handler: @escaping (_ user: User?, _ error: Error?) ->Void) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { (returnUser, returnError) in
            
            handler(returnUser, returnError)
        })
    }
    
    static func removeAllObservers(collectionID: String) {
        let itemDataRef = Database.database().reference().child("items").child(collectionID)
        itemDataRef.removeAllObservers()
    }
    
    static func updateItemCount(collectionID: String) {
        let refCollectionInfo = Database.database().reference().child("collections")
        getItemCount(collectionID: collectionID) { (count) in
            if let uid = Auth.auth().currentUser?.uid {
                let newCollection = ["itemCount": count] as [String : Any]
                print("Update \(collectionID)")
                print(count)
                refCollectionInfo.child(uid).child(collectionID).updateChildValues(newCollection)
            }
        }
    }
    
    static func getItemCount(collectionID: String, handler: @escaping (_ itemCount: Int) ->Void) {
        let itemDataRef = Database.database().reference().child("items").child(collectionID)
        itemDataRef.observe(.value, with: { (snapshot) in
            let itemSets = snapshot.value as? NSDictionary
            
            if let count = itemSets?.count {
                handler(count)
            }
        })
    }
    
    
    static func cacheImage(imageID: String, image: UIImage) {
        let fileManager = FileManager.default
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("\(imageID).png")
        let imageData = UIImagePNGRepresentation(image)
        
        if !fileManager.fileExists(atPath: path) {
            fileManager.createFile(atPath: path as String, contents: imageData, attributes: nil)
            print("cached image \(imageID)")
        }
        
    }
    
    static func getCachedImage(imageID: String) -> UIImage? {
        print("get cached image")
        let fileManager = FileManager.default
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("\(imageID).png")
        if fileManager.fileExists(atPath: path){
            if let image = UIImage(contentsOfFile: path) {
                print("Image returned \(imageID)")
                return image
            } else {
                print("Image not found")
                return nil
            }
        }else{
            print("No Image")
        }
        return nil
    }
    
    static func deleteImageFromCache(imageID: String){
        let fileManager = FileManager.default
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("\(imageID).png")
        if fileManager.fileExists(atPath: path){
            try! fileManager.removeItem(atPath: path)
            print("Delete Image \(imageID)")
        }else{
            print("Nothing to delete \(imageID)")
        }
    }
}
