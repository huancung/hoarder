//
//  CollectionCell.swift
//  Hoarder
//
//  Created by Huan Cung on 7/23/17.
//  Copyright © 2017 Huan Cung. All rights reserved.
//

import UIKit

class CollectionCell: UITableViewCell {
    @IBOutlet weak var nameText: UILabel!
    @IBOutlet weak var itemCountText: UILabel!
    @IBOutlet weak var categoryText: UILabel!
    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    public func updateUI(collection: CollectionType) {
        nameText.text = collection.collectionName
        itemCountText.text = "Items in this collection: \(collection.itemCount)"
        categoryText.text = "Category: \(collection.category)"
        descriptionText.text = collection.description
    }
    
    public func setEditIndex(index: Int) {
        editButton.tag = index
    }
    
    public func setFavorite(isFavorite: Bool) {
        if isFavorite {
            containerView.backgroundColor = UIColor(red: 255/255, green: 221/255, blue: 107/255, alpha: 1.0)
        } else {
            containerView.backgroundColor = UIColor.white
        }
    }
}
