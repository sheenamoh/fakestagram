//
//  SignUpViewController.swift
//  Instagram
//
//  Created by Skkz on 05/07/2016.
//  Copyright © 2016 Skkz. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SignUpViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var firebaseRef = FIRDatabase.database().reference()
    
    @IBAction func onSignUpBtnClicked(sender: AnyObject) {
        guard let email = emailTextField.text, password = passwordTextField.text, username = usernameTextField.text else {
            return
        }
        FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: { (user, error) in
            if let user = user {
                let userDict = ["email": email, "username": username]
                self.firebaseRef.child("users").child(user.uid).setValue(userDict)
                NSUserDefaults.standardUserDefaults().setValue(user.uid, forKeyPath: "uid")
                
                User.signIn(user.uid)

            } else {
                let controller = UIAlertController(title: "Error", message: (error?.localizedDescription), preferredStyle: .Alert)
                let dismissBtn = UIAlertAction(title: "Try Again", style: .Default, handler: nil)
                controller.addAction(dismissBtn)
                
                self.presentViewController(controller, animated: true, completion: nil)
            }
        })
    }
    

}
