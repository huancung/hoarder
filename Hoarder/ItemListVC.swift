//
//  ItemListVC.swift
//  Hoarder
//
//  Created by Huan Cung on 7/27/17.
//  Copyright © 2017 Huan Cung. All rights reserved.
//

import UIKit

class ItemListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var itemTableView: UITableView!
    var collectionUID: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        itemTableView.delegate = self
        itemTableView.dataSource = self
        itemTableView.backgroundColor = UIColor.clear
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as? ItemCell {
            //configureCell(cell: cell, indexPath: indexPath)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//    }
    
    func configureCell(cell: CollectionCell, indexPath: IndexPath) {
        
    }
    
    @IBAction func addEditItemPressed(_ sender: Any) {
        performSegue(withIdentifier: "addEditItemSegue", sender: collectionUID)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.identifier == "addEditItemSegue" {
            if let destination = segue.destination as? ItemVC {
                if let collectionUID = sender as? String {
                    destination.collectionUID = collectionUID
                }
            }
        }
    }

}
