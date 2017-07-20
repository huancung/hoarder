//
//  StyleButton.swift
//  Hoarder
//
//  Created by Huan Cung on 7/18/17.
//  Copyright © 2017 Huan Cung. All rights reserved.
//

import UIKit

private var styleButtonKey = false

extension UIButton {
    @IBInspectable var styleButton: Bool {
        get{
            return styleButtonKey
        }
        
        set {
            styleButtonKey = newValue
            
            if styleButtonKey {
                self.layer.cornerRadius = 5.0
                self.layer.borderWidth = 1.0
                self.layer.borderColor = UIColor.white.cgColor
            } else {
                self.layer.cornerRadius = 0
                self.layer.borderWidth = 0
                self.layer.borderColor = nil
            }
        }
    }
}
