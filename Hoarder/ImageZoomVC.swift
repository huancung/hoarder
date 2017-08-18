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
    
    @IBAction func saveImagePressed(_ sender: Any) {
        let alert = UIAlertController(title: "Nice Picture!", message: "Save image to phone?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Save", style: .default) { (alert) in
            UIImageWriteToSavedPhotosAlbum(self.image!, self, #selector(self.image(image:didFinishSavingWithError:contextInfo:)), nil)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            print("Save Canceled")
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func donePressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafeRawPointer) {
        if error == nil {
            let ac = UIAlertController(title: "Saved!", message: "Image is now saved to your phone.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        } else {
            let ac = UIAlertController(title: "Save error", message: error?.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
