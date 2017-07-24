//
//  CollectionType.swift
//  Hoarder
//
//  Created by Huan Cung on 7/22/17.
//  Copyright © 2017 Huan Cung. All rights reserved.
//

import Foundation

public class CollectionType {
    private var _collectionName = ""
    private var _category = ""
    private var _description = ""
    private var _collectionID = ""
    private var _ownerID = ""
    private var _itemCount = 0
    private var _dateCreated = 0.0
    private var _dateCreatedString = ""
    
    init(collectionName: String, category: String, description: String, collectionID: String, itemCount: Int, ownerID: String, creationDateString: String, creationDate: Double) {
        _collectionName = collectionName
        _category = category
        _description = description
        _collectionID = collectionID
        _ownerID = ownerID
        _dateCreated = creationDate
        _dateCreatedString = creationDateString
        _itemCount = itemCount
    }
    
    var collectionName: String {
        get{
            return _collectionName
        }
    }
    
    var category: String {
        get{
            return _category
        }
    }
    
    var description: String {
        get{
            return _description
        }
    }
    
    var collectionID: String {
        get{
            return _collectionID
        }
    }
    
    var ownerID: String {
        get{
            return _ownerID
        }
    }
    
    var dateCreated: Double {
        get{
            return _dateCreated
        }
    }
    
    var dateCreatedString: String {
        get{
            return _dateCreatedString
        }
    }
    
    var itemCount: Int {
        get{
            return _itemCount
        }
    }
    
}
