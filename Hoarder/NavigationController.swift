//
//  NavigationController.swift
//  Hoarder
//
//  Created by Huan Cung on 8/6/17.
//  Copyright © 2017 Huan Cung. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navbar = self.navigationBar
        navbar.tintColor = UIColor.darkGray
        navbar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.darkGray]
    }


}
