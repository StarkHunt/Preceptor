//
//  EditProfileVC.swift
//  JBTFoundation
//
//  Created by Sugat Nagavkar on 07/09/16.
//  Copyright © 2016 Sugat Nagavkar. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage


class EditProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    let reference = FIRDatabase.database().reference()
    let storage = FIRStorage.storage().reference()
    let currentUser = FIRAuth.auth()?.currentUser
    
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var gender: UISegmentedControl!
    
    
    override func viewDidLoad() {
       
        //Inputs user values available into the profile form.
            firstName.delegate = self
            lastName.delegate = self
        
            userImage.layer.cornerRadius = userImage.frame.size.width / 2
        userImage.clipsToBounds = true
        
        reference.child("users").child(currentUser!.uid).observe(.value, with: { (snapshot) in
            // Get user value
            if !snapshot.exists() { return }
            
            let snapshotValue = snapshot.value as? NSDictionary
            self.firstName.text = snapshotValue?["firstName"] as? String
            self.lastName.text = snapshotValue?["lastName"] as? String

            let genderType = snapshotValue?["gender"] as? String
              
            if genderType == "Male"{
                self.gender.selectedSegmentIndex = 0
            }else if genderType == "Female"{
                self.gender.selectedSegmentIndex = 1
            }else{
                self.gender.selectedSegmentIndex = 2
            }
            
            //extract image
            if snapshot.hasChild("userPhoto"){
                // set image locatin
                let filePath = "\(FIRAuth.auth()!.currentUser!.uid)/\("userPhoto")"
                // Assuming a < 10MB file, though you can change that
                self.storage.child(filePath).data(withMaxSize: 10*1024*1024, completion: { (data, error) in
                    
                    let userPhoto = UIImage(data: data!)
                    self.userImage.image = userPhoto
                })
            }else{
                print("Error Downloading")
                
            }
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    @IBAction func done(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func save(_ sender: AnyObject) {
        
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpeg"
        let filePath = "\(FIRAuth.auth()!.currentUser!.uid)/\("userPhoto")"
        
        storage.child(filePath).put(UIImageJPEGRepresentation(userImage.image!, 0.8)!, metadata: metaData) { (metaData, error) in
            if error == nil {
                let downloadURL = metaData!.downloadURL()!.absoluteString
                self.reference.child("users").child(FIRAuth.auth()!.currentUser!.uid).updateChildValues(["userPhoto": downloadURL])
                print("Uploaded")
            }else{
                print("Error Uploading")
            }
            
        }
        
        var gType = String()
        let fName = firstName.text!
        let lName = lastName.text!
        
        //        let imageData = UIImageJPEGRepresentation(userImage.image!, 1)
        
        
        if gender.selectedSegmentIndex == 0 {
            gType = "Male"
        }else if gender.selectedSegmentIndex == 1 {
            gType = "Female"
        }else{
            gType = "Other"
        }
        
        if (fName.isEmpty || lName.isEmpty){
            
            sendAlert("All Fields are required creating profile")
            return
            
        }
        
        reference.child("users").child((currentUser?.uid)!).setValue(["firstName": fName, "lastName": lName, "gender": gType])
        
        sendAlert("Data Saved")
        
    }//end of save function
    
    
    @IBAction func chooseImage(_ sender: AnyObject) {
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        self.present(pickerController, animated: true, completion: nil)
    }
   
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        userImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        firstName.resignFirstResponder()
        lastName.resignFirstResponder()
        return true
    }
    
    func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        firstName.resignFirstResponder()
        lastName.resignFirstResponder()
        self.view.endEditing(true)
    }
    
    func sendAlert(_ message : String){
        
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
        
    }

    
    
}




