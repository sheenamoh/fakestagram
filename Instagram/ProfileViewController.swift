//
//  ProfileViewController.swift
//  Instagram
//
//  Created by Skkz on 05/07/2016.
//  Copyright © 2016 Skkz. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var userProfilePic: UIImageView!
    @IBOutlet weak var postLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var userNameBar: UINavigationBar!
    
    let firebaseRef = FIRDatabase.database().reference()
    let fireStorageRef = FIRStorage.storage().reference()
    var feedofImages = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageAppending()
        // getUserName()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logOutBtn(sender: UIButton) {
        try! FIRAuth.auth()!.signOut()
        User.removeUserUid()
    }
    
    //    @IBAction func logOutBtn(sender: UIButton) {
    //        try! FIRAuth.auth()!.signOut()
    //        User.removeUserUid()
    //    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.feedofImages.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let image = feedofImages[indexPath.row]
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("imagecell", forIndexPath: indexPath) as! PostCollectionViewCell
        let url = NSURL(string: image)
        cell.postImage.sd_setImageWithURL(url)
        return cell
    }
    
    func imageAppending() {
        
        let userRef = firebaseRef.child("users").child(User.currentUserUid()!)
        userRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let user = User(snapshot: snapshot) {
                self.userNameBar.topItem?.title = user.userName
                self.followingLabel.text = "Following:\(user.followCount)"
                self.followersLabel.text = "Followers:\(user.followersCount)"
                self.postLabel.text = "Posts: \(user.postCount)"
            }
        })
        
        userRef.child("uploaded").observeEventType(.Value, withBlock: { (snapshot) in
            if let uploadedDict = snapshot.value as? [String: Bool]{
                for (key, _) in uploadedDict {
                    self.firebaseRef.child("Images").child(key).observeSingleEventOfType(.ChildAdded, withBlock: { (uploadedSnapshot) in
                        let image = uploadedSnapshot.value as? String ///here gt problem
                        self.feedofImages.append(image!)
                        self.collectionView.reloadData()
                        }
                    )}
            }
        })

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
