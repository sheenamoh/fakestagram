//
//  CameraViewController.swift
//  Instagram
//
//  Created by Skkz on 05/07/2016.
//  Copyright © 2016 Skkz. All rights reserved.
//

import UIKit
import Fusuma
import FirebaseDatabase
import FirebaseStorage

class CameraViewController: UIViewController, FusumaDelegate {
    
    var firebaseRef = FIRDatabase.database().reference()
    let storageRef = FIRStorage.storage().referenceForURL("gs://fakestagram-8cb01.appspot.com/images")
    var base64string: NSString!
    var userName: String!
    override func viewDidLoad() {
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        fusumaInit()
        getUserName()
    }
    
    func fusumaInit() {
    let fusuma = FusumaViewController()
    fusuma.delegate = self
    fusuma.hasVideo = true
    self.presentViewController(fusuma, animated: true, completion: nil)
    }
    
    // Return the image which is selected from camera roll or is taken via the camera.
    func fusumaImageSelected(image: UIImage) {
        let imageName = NSUUID().UUIDString
        let imageRef = FIRStorage.storage().reference().child("Images").child("\(imageName).png")
        if let uploadData = UIImageJPEGRepresentation(image, 0.1){
            imageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error?.localizedDescription)
                    return
                }
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    let imageDict = ["imageURL": imageUrl, "userID": User.currentUserUid()!, "userName": self.userName, "likesCount": 0]
                    self.firebaseRef.child("Images").child(imageName).setValue(imageDict)
                    self.firebaseRef.child("users").child(User.currentUserUid()!).child("uploaded").child(imageName).setValue(true)
                    let commentDict = ["imageUID": imageName]
                    self.firebaseRef.child("Comments").setValue(commentDict)
                    
                }
            })
        }
        
        self.tabBarController?.selectedIndex = 0
        print("Image selected")
    }
    
    func getUserName() {
        let firebaseRef = FIRDatabase.database().reference()
        let userRef = firebaseRef.child("users")
        
        userRef.observeEventType(.ChildAdded, withBlock: {(snapshot) in
            
            if let tweetDict = snapshot.value as? [String : AnyObject]{
                print (snapshot.key)
                if (snapshot.key == User.currentUserUid()) {
                    if let tweetText = tweetDict["username"] as? String{
                        self.userName = tweetText
                    }
                }
            }
        })
    }
    
    // Return the image but called after is dismissed.
    func fusumaDismissedWithImage(image: UIImage) {
        
        print("Called just after FusumaViewController is dismissed.")
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: NSURL) {
        print("VIdeo Completed")
    }
    
    // When camera roll is not authorized, this method is called.
    func fusumaCameraRollUnauthorized() {
        
        print("Camera roll unauthorized")
    }
    
    func fusumaClosed() {
        self.tabBarController?.selectedIndex=0
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
