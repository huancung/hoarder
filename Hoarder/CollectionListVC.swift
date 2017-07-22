//
//  CollectionListVC.swift
//  Hoarder
//
//  Created by Huan Cung on 7/18/17.
//  Copyright © 2017 Huan Cung. All rights reserved.
//

import UIKit

class CollectionListVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func addCollectionPressed(_ sender: Any) {
        performSegue(withIdentifier: "NewCollectionSegue", sender: nil)
    }
}
