//
//  ViewController.swift
//  Hoarder
//
//  Created by Huan Cung on 7/18/17.
//  Copyright © 2017 Huan Cung. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func loginButtonPressed(_ sender: Any) {
        if emailText.text == nil {
            
        } else if passwordText == nil {
            
        }
        performSegue(withIdentifier: "CollectionListSegue", sender: nil)
    }
    
    @IBAction func newAccountButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "SignUpSegue", sender: nil)
    }
    
    @IBAction func forgotButtonPressed(_ sender: Any) {
        
    }
}

