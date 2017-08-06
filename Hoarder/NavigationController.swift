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

//        if let topItem = self.navigationBar.topItem {
//            let button = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
//            
//            topItem.backBarButtonItem = button
//        }
        
        let navbar = self.navigationBar
        navbar.tintColor = UIColor.darkGray
        navbar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.darkGray]
    }


}
