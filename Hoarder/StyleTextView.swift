//
//  StyleTextView.swift
//  Hoarder
//
//  Created by Huan Cung on 7/21/17.
//  Copyright © 2017 Huan Cung. All rights reserved.
//

import UIKit

private var roundedKey = false

extension UITextView {
    @IBInspectable var roundedCorners: Bool {
        get{
            return roundedKey
        }
        
        set {
            roundedKey = newValue
            
            if roundedKey {
                self.layer.cornerRadius = 5.0
            } else {
                self.layer.cornerRadius = 0
            }
        }
    }
}

extension UIPickerView {
    @IBInspectable var roundedCorners: Bool {
        get{
            return roundedKey
        }
        
        set {
            roundedKey = newValue
            
            if roundedKey {
                self.layer.cornerRadius = 5.0
            } else {
                self.layer.cornerRadius = 0
            }
        }
    }
}
