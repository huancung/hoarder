//
//  ItemType.swift
//  Hoarder
//
//  Created by Huan Cung on 8/3/17.
//  Copyright © 2017 Huan Cung. All rights reserved.
//

import Foundation

public class ItemType {
    private var _ownerID = ""
    private var _collectionID = ""
    private var _itemID = ""
    private var _itemName = ""
    private var _description = ""
    private var _imageID = ""
    private var _imageURL = ""
    private var _dateAdded = 0.0
    private var _dateAddedString = ""
    
    init(ownerID: String, collectionID: String, itemID: String, itemName: String, description: String, imageID: String, imageURL: String, dateAdded: Double, dateAddedString: String) {
        _ownerID = ownerID
        _collectionID = collectionID
        _itemID = itemID
        _itemName = itemName
        _description = description
        _imageID = itemID
        _imageURL = imageURL
        _dateAdded = dateAdded
        _dateAddedString = dateAddedString
    }

    var ownerID: String {
        get{
            return _ownerID
        }
    }
    
    var collectionID: String {
        get{
            return _collectionID
        }
    }
    
    var itemID: String {
        get{
            return _itemID
        }
    }
    
    var itemName: String {
        get{
            return _itemName
        }
    }
    
    var description: String {
        get{
            return _description
        }
    }
    
    var imageID: String {
        get{
            return _imageID
        }
    }
    
    var imageURL: String {
        get{
            return _imageURL
        }
    }
    
    var dateAdded: Double {
        get{
            return _dateAdded
        }
    }
    
    var dateAddedString: String {
        get{
            return _dateAddedString
        }
    }
}
