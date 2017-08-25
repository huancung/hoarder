//
//  SignUpVC.swift
//  Hoarder
//
//  Created by Huan Cung on 7/18/17.
//  Copyright © 2017 Huan Cung. All rights reserved.
//

import UIKit

class SignUpVC: UIViewController {
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var reenterPasswordText: UITextField!
    @IBOutlet weak var firstNameText: UITextField!
    @IBOutlet weak var lastNameText: UITextField!
    
    var blurEffectView: UIVisualEffectView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.regular)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        //dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func dismissKeyboard(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @IBAction func createNewAccountButtonPressed(_ sender: Any) {
        var errors = false
        var errorMessage = ""
        
        // Verifying entries
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
            BusyModal.startBusyModalAndHideNav(targetViewController: self)
            
            DataAccessUtilities.createNewAccount(email: emailText.text!, password: passwordText.text!, handler: { (returnUser, returnError) in
                if let user = returnUser {
                    print(user.uid)
                    print(user.email!)
                    
                    var firstName = ""
                    var lastName = ""
                    
                    if let fName = self.firstNameText.text, !fName.isEmpty {
                        firstName = fName
                    }
                    
                    if let lName = self.lastNameText.text, !lName.isEmpty {
                        lastName = lName
                    }
                    
                    DataAccessUtilities.savePersonalInfo(uid: user.uid, firstName: firstName, lastName: lastName, email: user.email!)
                    user.sendEmailVerification(completion: nil)
                    
                    BusyModal.stopBusyModalAndShowNav(targetViewController: self)
                    
                    AlertUtil.messageThenPop(title: "Hooray!", message: "You're account has been created! Please verify your email. Happy hoarding!", targetViewController: self)
                } else if let error = returnError {
                    BusyModal.stopBusyModal()
                    AlertUtil.alert(message: error.localizedDescription, targetViewController: self)
                }
            })
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
