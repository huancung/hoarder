//
//  ParentViewController.swift
//  Hoarder
//
//  Created by Huan Cung on 8/8/17.
//  Copyright © 2017 Huan Cung. All rights reserved.
//

import UIKit

protocol ParentViewController {
    var willReloadData: Bool { get set }
}

extension ParentViewController where Self: UIViewController {

}
