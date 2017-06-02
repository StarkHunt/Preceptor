//
//  SignInViewController.swift
//  JBTFoundation
//
//  Created by Sugat Nagavkar on 02/09/16.
//  Copyright © 2016 Sugat Nagavkar. All rights reserved.
//

import UIKit
import Firebase

class SignInViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var viewSignIn: UIView!
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var loginProperty: UIButton!
    @IBOutlet weak var registerProperty: UIButton!
    
    
    @IBAction func signIn(_ sender: AnyObject) {
        
        let userEmailText = userEmail.text!
        let userPasswordText = userPassword.text!
        
        if (userEmailText.isEmpty || userPasswordText.isEmpty){
        
        sendAlert("Cannot Sign In. Please Enter Empty Fields")
            
        return
        }
        
        //login with Firebase
        FIRAuth.auth()?.signIn(withEmail: userEmailText, password: userPasswordText, completion: {
            user, error in
            
            
            if error != nil {
                self.sendAlert((error?.localizedDescription)!)
                //self.sendAlert("Email or Password Incorrect. Please reenter.")
                return
            }else{
        
                
                if let user = FIRAuth.auth()?.currentUser{
                    
                    if user.isEmailVerified{
                        self.performSegue(withIdentifier: "swreveal", sender: self)
                    }else{
                        self.sendAlert("Email or Password Incorrect. Please reenter.")
                        //self.sendAlert("This user has not been verified")
                    }
                }
                
                
                
        //
            }
        
        })
        
        
    }//end of sign in action
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        userEmail.resignFirstResponder()
        userPassword.resignFirstResponder()
        return true;
    }
    
    func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        userEmail.resignFirstResponder()
        userPassword.resignFirstResponder()
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        
        
        print("Now in Log In screen")
        //corner radius for buttons
        
        loginProperty.layer.cornerRadius = 5
        registerProperty.layer.cornerRadius = 5
        
        
        
        self.navigationController?.isNavigationBarHidden = true
        
//        
//        FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
//            
//            if user != nil{
//                self.performSegue(withIdentifier: "swreveal", sender: self)
//            }
//        })
        
        view.backgroundColor = UIColor(red: 61/255, green: 91/255, blue: 151/255, alpha: 1)
    
        viewSignIn.layer.cornerRadius = 5
        viewSignIn.layer.masksToBounds = true
        //self.navigationController?.navigationBar.hidden = true
        userEmail.delegate = self
        userPassword.delegate = self
        
    }
    
    
    func sendAlert(_ message : String){
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }//end of sendAlert func
    
}
