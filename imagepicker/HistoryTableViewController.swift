//
//  HistoryTableViewController.swift
//  imagepicker
//
//  Created by Sugat Nagavkar on 22/04/17.
//  Copyright © 2017 Sara Robinson. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class HistoryTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var more: UIBarButtonItem!
    
    var users = [UserHistory]()
    
    let reference =
        FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        more.target = self.revealViewController()
        
        more.action = #selector(SWRevealViewController.revealToggle(_:))
        
        //(SWRevealViewController.revealToggle(_:))
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
        let currentUser = FIRAuth.auth()?.currentUser
        
        reference.child("users").child(currentUser!.uid).child("history").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let user = UserHistory()
                user.setValuesForKeys(dictionary)
                self.users.append(user)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
            print(snapshot)
        })
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = users[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! HistoryTableViewCell
        
        
        if let url = NSURL(string: user.picture!){
            if let data = NSData(contentsOf: url as URL){
                cell.picture.image = UIImage(data: data as Data)
            }
        }
        
        cell.locationName.text = user.locationName
        return cell
        
    }
    
}


