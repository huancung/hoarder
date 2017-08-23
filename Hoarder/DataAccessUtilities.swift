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
    
    static func deleteImageFromStorage(imageID: String, collectionID: String) {
        let imageRef = Storage.storage().reference().child("ItemImages").child(collectionID).child("\(imageID).png")
        imageRef.delete { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
}
