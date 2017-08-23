//
//  AlertUtilities.swift
//  Hoarder
//
//  Created by Huan Cung on 7/19/17.
//  Copyright © 2017 Huan Cung. All rights reserved.
//

import Foundation
import UIKit

public class AlertUtil {
    static let sharedInstance = AlertUtil()
    
    static func alert(message: String, targetViewController: UIViewController) {
        let alert = UIAlertController(title: "Oops!", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        targetViewController.present(alert, animated: true, completion: nil)
    }
    
    static func messageThenPop(title: String, message: String, targetViewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { (alert) in
            targetViewController.navigationController?.popViewController(animated: true)
        })
        targetViewController.present(alert, animated: true, completion: nil)
    }
    
    static func message(title: String, message: String, targetViewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        targetViewController.present(alert, animated: true, completion: nil)
    }
}
