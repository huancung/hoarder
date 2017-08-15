//
//  ImageZoomVC.swift
//  Hoarder
//
//  Created by Huan Cung on 8/14/17.
//  Copyright © 2017 Huan Cung. All rights reserved.
//

import UIKit

class ImageZoomVC: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.setHidesBackButton(true, animated: true)
        
        if let zoomableImage = image {
            imageView.image = zoomableImage
        } else {
            imageView.image = UIImage(named: "imagePlaceholder")
        }
        
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 6.0
    }
    
    @IBAction func donePressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
