//
//  PasswordResetViewController.swift
//  imagepicker
//
//  Created by Sugat Nagavkar on 03/05/17.
//  Copyright © 2017 Sara Robinson. All rights reserved.
//

import UIKit
import Firebase

class PasswordResetViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var userEmail: UITextField!
    
    @IBOutlet weak var resetView: UIView!
    
    @IBOutlet weak var resetPasswordProperty: UIButton!
    
    @IBOutlet weak var signInProperty: UIButton!
    
    override func viewDidLoad() {
        
        //make buttons corner radius round
        resetPasswordProperty.layer.cornerRadius = 5
        signInProperty.layer.cornerRadius = 5
        
        view.backgroundColor = UIColor(red: 61/255, green: 91/255, blue: 151/255, alpha: 1)
        
        resetView.layer.cornerRadius = 5
        resetView.layer.masksToBounds = true

        userEmail.delegate = self
        
        
        
    }
    
    @IBAction func resetPassword(_ sender: UIButton) {
        
        let userEmailText = userEmail.text!
        
        
        if (userEmailText.isEmpty){
            
            sendAlert("Please Enter Email address to Reset Password")
            return
        }
        
        //reset password
        
        FIRAuth.auth()?.sendPasswordReset(withEmail: userEmailText, completion: { (error) in
            
            if error != nil{
                self.sendAlert((error?.localizedDescription)!)
                return
                
            }else{
                self.sendAlert("Password Reset Email sent to \(userEmailText).")
                self.userEmail.text = ""
            }
        })
        
        
        
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        userEmail.resignFirstResponder()
        return true;
    }
    
    func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        userEmail.resignFirstResponder()
        self.view.endEditing(true)
    }
    
    func sendAlert(_ message : String){
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }//end of sendAlert func
    
    
    
    
    
}
