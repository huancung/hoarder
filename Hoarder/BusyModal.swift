//
//  BusyModal.swift
//  
//
//  Created by Huan Cung on 8/10/17.
//
//

import UIKit

public class BusyModal {
    static let sharedInstance = BusyModal()
    static let modal = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))
    
    static func startBusyModalAndHideNav(targetViewController: UIViewController) {
        targetViewController.navigationItem.backBarButtonItem?.isEnabled = false
        targetViewController.navigationItem.leftBarButtonItem?.isEnabled = false
        targetViewController.navigationItem.rightBarButtonItem?.isEnabled = false
        startBusyModal(targetViewController: targetViewController)
    }
    
    static func stopBusyModalAndShowNav(targetViewController: UIViewController) {
        targetViewController.navigationItem.backBarButtonItem?.isEnabled = true
        targetViewController.navigationItem.leftBarButtonItem?.isEnabled = true
        targetViewController.navigationItem.rightBarButtonItem?.isEnabled = true
        stopBusyModal()
    }
    
    /**
     Adds a busy modal overlay that blocks out controls while app is busy.
     - parameters:
        - targetViewController: ViewController that the modal will be added to.
     */
    static func startBusyModal(targetViewController: UIViewController) {
        stopBusyModal()
        if let view = targetViewController.view {
            modal.frame = view.bounds
            modal.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
            actInd.center = modal.center
            actInd.hidesWhenStopped = true
            actInd.activityIndicatorViewStyle = .whiteLarge
            modal.addSubview(actInd)
            actInd.startAnimating()
            
            view.addSubview(modal)
        }
    }
    
    /**
     Removes a busy modal from the view if there is one being displayed.
     */
    static func stopBusyModal() {
        if modal.superview != nil {
            modal.removeFromSuperview()
        }
    }
}
