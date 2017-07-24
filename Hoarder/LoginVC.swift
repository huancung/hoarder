//
//  ViewController.swift
//  Hoarder
//
//  Created by Huan Cung on 7/18/17.
//  Copyright © 2017 Huan Cung. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginVC: UIViewController {
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var rememberMeSwitch: UISwitch!
    
    var blurEffectView: UIVisualEffectView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.regular)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        getStoredLogin()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func dismissKeyboard(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        if let email = emailText.text, !email.isEmpty {
            var errors = false
            var password = ""
            
            if let pw = passwordText.text, !pw.isEmpty {
                password = pw
            } else {
                AlertUtil.alert(message: "You forgot to enter your password!", targetViewController: self)
                errors = true
            }
            
            if !errors {
                startBusyModal()
                Auth.auth().signIn(withEmail: email, password: password, completion: { (returnUser, returnError) in
                    if let user = returnUser {
                        print(user.uid)
                        print(user.email!)
                        self.stopBusyModal()
                        
                        if self.rememberMeSwitch.isOn {
                            self.storeLogin(email: email, password: password)
                        } else {
                            self.deleteStoredLogin()
                        }
                        
                        if user.isEmailVerified {
                            self.performSegue(withIdentifier: "CollectionListSegue", sender: nil)
                        } else {
                            AlertUtil.alert(message: "Please verify your email before logging in!", targetViewController: self)
                        }
                        
                    } else if let error = returnError {
                        AlertUtil.alert(message: error.localizedDescription, targetViewController: self)
                        self.stopBusyModal()
                    }
                    
                })

            }
            
        }
    }
    
    @IBAction func newAccountButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "SignUpSegue", sender: nil)
    }
    
    @IBAction func forgotButtonPressed(_ sender: Any) {
        
    }
    
    /**
     Stores the login information.
     - parameters:
        - email: User's email address
        - password: User's password
    */
    private func storeLogin(email: String, password: String) {
        let defaults = UserDefaults.standard
        
        defaults.set(email, forKey: "email")
        defaults.set(password, forKey: "password")
        defaults.set(rememberMeSwitch.isOn, forKey: "remember")
    }
    
    /**
     Deletes any stored login information.
    */
    private func deleteStoredLogin() {
        let defaults = UserDefaults.standard
        
        defaults.set("", forKey: "email")
        defaults.set("", forKey: "password")
        defaults.set(rememberMeSwitch.isOn, forKey: "remember")
    }
    
    /**
     Retrieves stored login information.
    */
    private func getStoredLogin() {
        let defaults = UserDefaults.standard
        
        if let email = defaults.string(forKey: "email") {
            emailText.text = email
        }
        
        if let password = defaults.string(forKey: "password") {
            passwordText.text = password
        }
        
        rememberMeSwitch.isOn = defaults.bool(forKey: "remember")
    }
    
    /**
     Removes a busy modal from the view if there is one being displayed.
     */
    private func stopBusyModal() {
        if blurEffectView != nil {
            blurEffectView?.removeFromSuperview()
        }
    }
    
    /**
     Adds a busy modal overlay that blocks out controls while app is busy.
     */
    private func startBusyModal() {
        if let modal = blurEffectView {
            
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

