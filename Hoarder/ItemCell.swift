//
//  ItemCell.swift
//  Hoarder
//
//  Created by Huan Cung on 7/27/17.
//  Copyright © 2017 Huan Cung. All rights reserved.
//

import UIKit

class ItemCell: UITableViewCell {
    @IBOutlet weak var thumbImage: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    public func updateUI(item: ItemType) {
        nameLbl.text = item.itemName
        descLbl.text = item.description
        
        if item.itemImage == nil && !item.imageURL.isEmpty {
            let url = URL(string: item.imageURL)!
            
            DispatchQueue.global().async {
                do {
                    let data = try Data(contentsOf: url)
                    DispatchQueue.main.async {
                        let image = UIImage(data: data)
                        self.thumbImage.image = image
                        item.itemImage = image
                    }
                } catch {
                    print("Unable to get image!")
                }
            }
        } else if item.itemImage != nil {
            self.thumbImage.image = item.itemImage
        } else {
            self.thumbImage.image = UIImage(named: "imagePlaceholder")
        }
        
    }
    
}
