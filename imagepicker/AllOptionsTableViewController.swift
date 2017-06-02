//
//  AllOptionsTableViewController.swift
//  JBTFoundation
//
//  Created by Sugat Nagavkar on 01/09/16.
//  Copyright © 2016 Sugat Nagavkar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class AllOptionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var userName: UILabel!
    var userNameString = String()
    
    @IBOutlet weak var imageView: UIImageView!
    let reference = FIRDatabase.database().reference()

    
    var allOptionsArray = ["Home", "History"]
    var allOptionsImageArray = [UIImage(named: "home"), UIImage(named: "history")]
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allOptionsArray.count
    }
    
    @IBAction func handleLogout(_ sender: UIButton) {
        
        do{
            try FIRAuth.auth()?.signOut()
        }catch let errorType{
            print(errorType)
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: allOptionsArray[(indexPath as NSIndexPath).row], for: indexPath) as! AllOptionsTableViewCell
                cell.customLabel.text = allOptionsArray[(indexPath as NSIndexPath).row]
        
        
        cell.customImage.image = allOptionsImageArray[(indexPath as NSIndexPath).row]
        return cell
    }
    
    
    override func viewDidLoad() {
        
        //make circular imageview
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
        
        
        
        
        let storage = FIRStorage.storage().reference()
        //let reference = FIRDatabase.database().referenceFromURL("https://jbtlogin-81584.firebaseio.com")
        
        
        let currentUser = FIRAuth.auth()?.currentUser
        
        
        reference.child("users").child(currentUser!.uid).observe(.value, with: { (snapshot) in
            // Get user value
            
            //print(snapshot)
            if !snapshot.exists() { return }
            
            var firstName = ""
            var lastName = ""
            let snapshotValue = snapshot.value as? NSDictionary
            
            
            //let name = snapshotValue["displayName"] as? String
            
            if let firstN = snapshotValue?["firstName"] as? String{
                firstName = firstN
            }
            if let lastN = snapshotValue?["lastName"] as? String{
                lastName = lastN
            }
//            if (firstName == nil || lastName == nil){
//                self.userName.text = "Preceptor User"
//            }else{
                self.userName.text = "\(firstName) \(lastName)"
            //}
            
            if snapshot.hasChild("userPhoto"){
                // set image locatin
                let filePath = "\(FIRAuth.auth()!.currentUser!.uid)/\("userPhoto")"
                // Assuming a < 10MB file, though you can change that
                storage.child(filePath).data(withMaxSize: 10*1024*1024, completion: { (data, error) in
                    
                    let userPhoto = UIImage(data: data!)
                    self.imageView.image = userPhoto
                })
            }else{
                print("Error Downloading")
                
            }
            
        })
    
    }
    
  

}
