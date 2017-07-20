//
//  SignUpVC.swift
//  Hoarder
//
//  Created by Huan Cung on 7/18/17.
//  Copyright © 2017 Huan Cung. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SignUpVC: UIViewController {
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var reenterPasswordText: UITextField!
    var overlay : UIView?
    var blurEffectView: UIVisualEffectView?
    var currentModal: UIVisualEffectView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overlay = UIView(frame: view.frame)
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.regular)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createNewAccountButtonPressed(_ sender: Any) {
        var errors = false
        var errorMessage = ""
        
        if let text = emailText.text, text.isEmpty {
            errorMessage = "\(errorMessage)\nEmail is required."
            errors = true
        }
        
        if let text = passwordText.text, text.isEmpty {
            errorMessage = "\(errorMessage)\nPassword is required."
            errors = true
        }
        
        if (passwordText.text != nil && reenterPasswordText.text != nil && passwordText.text != reenterPasswordText.text) {
            errorMessage = "\(errorMessage)\nPassword does not match."
            errors = true
        }
        
        if errors {
            AlertUtil.alert(message: errorMessage, targetViewController: self)
        } else {
            //Create account
            self.view.endEditing(true)
            startBusyModal()
            Auth.auth().createUser(withEmail: emailText.text!, password: passwordText.text!, completion: { (returnUser, returnError) in
                if let user = returnUser {
                    print(user.uid)
                    print(user.email!)
                    self.stopBusyModal()
                    
                    //Todo Save Personal info
                    
                    //Auto login at this point
                    AlertUtil.message(title: "Hooray!", message: "You're account has been created! Happy hoarding!", targetViewController: self)
                    //self.dismiss(animated: true, completion: nil)
                } else if let error = returnError {
                    self.stopBusyModal()
                    AlertUtil.alert(message: error.localizedDescription, targetViewController: self)
                }
            })
            
        }
        
        
    }
    
    /**
     Removes a busy modal from the view if there is one being displayed.
    */
    func stopBusyModal() {
        if currentModal != nil {
            currentModal?.removeFromSuperview()
        }
    }
    
    /**
     Adds a busy modal overlay that blocks out controls while app is busy.
    */
    func startBusyModal() {
        if let modal = blurEffectView {
            currentModal = modal

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
    
    @IBAction func dismissKeyboard(_ sender: Any) {
        self.view.endEditing(true)
    }
}
