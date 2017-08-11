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
    
    override func viewDidAppear(_ animated: Bool) {
        logout()
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
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
                BusyModal.startBusyModal(targetViewController: self)
                Auth.auth().signIn(withEmail: email, password: password, completion: { (returnUser, returnError) in
                    if let user = returnUser {
                        print(user.uid)
                        print(user.email!)
                        BusyModal.stopBusyModal()
                        
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
                        BusyModal.stopBusyModal()
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
 
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

