//
//  UserViewController.swift
//  Instagram
//
//  Created by Skkz on 12/07/2016.
//  Copyright © 2016 Skkz. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class UserViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var userUID = String()
    var userFeed = [String]()
    var firebaseRef = FIRDatabase.database().reference()
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var postLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getInfo()
        self.collectionView.reloadData()
        // Do any additional setup after loading the view.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.userFeed.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let image = userFeed[indexPath.row]
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("imagecell", forIndexPath: indexPath) as! UserCollectionViewCell
        
        let url = NSURL(string: image)
        cell.userImageFeed.sd_setImageWithURL(url)
        return cell
    }
    
    
    @IBAction func followBtn(sender: UIButton) {
        
        let userRef = firebaseRef.child("users").child(User.currentUserUid()!)
        
        
        userRef.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            if var post = currentData.value as? [String : AnyObject] {
                let uid = self.userUID
                var following : Dictionary<String, Bool>
                following = post["following"] as? [String : Bool] ?? [:]
                var followCount = post["followCount"] as? Int ?? 0
                if let _ = following[uid] {
                    // Unstar the post and remove self from stars
                    followCount -= 1
                    following.removeValueForKey(uid)
                    dispatch_async(dispatch_get_main_queue(), {
                        sender.setTitle("Follow", forState: .Normal)
                        sender.backgroundColor = UIColor.grayColor()
                        sender.setTitleColor(UIColor.blueColor(), forState: .Normal)
                    })
                    
                } else {
                    // Star the post and add self to stars
                    followCount += 1
                    following[uid] = true
                    dispatch_async(dispatch_get_main_queue(), {
                        sender.setTitle("Following", forState: .Normal)
                        sender.backgroundColor = UIColor.greenColor()
                        sender.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                    })
                }
                post["followCount"] = followCount
                post["following"] = following
                
                // Set value and report transaction success
                currentData.value = post
                
                return FIRTransactionResult.successWithValue(currentData)
            }
            return FIRTransactionResult.successWithValue(currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        
        let currentUserRef = firebaseRef.child("users").child(self.userUID)
        
        currentUserRef.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            let uid = User.currentUserUid()!
            if var post = currentData.value as? [String : AnyObject] {
                var followers : Dictionary<String, Bool>
                followers = post["followers"] as? [String : Bool] ?? [:]
                var followerCount = post["followerCount"] as? Int ?? 0
                if let _ = followers[uid] {
                    // Unstar the post and remove self from stars
                    followerCount -= 1
                    followers.removeValueForKey(uid)
                    dispatch_async(dispatch_get_main_queue(), {
                        sender.setTitle("Follow", forState: .Normal)
                        sender.backgroundColor = UIColor.grayColor()
                        sender.setTitleColor(UIColor.blueColor(), forState: .Normal)
                    })
                    
                } else {
                    // Star the post and add self to stars
                    followerCount += 1
                    followers[uid] = true
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        sender.setTitle("Following", forState: .Normal)
                        sender.backgroundColor = UIColor.greenColor()
                        sender.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                    })
                }
                post["followerCount"] = followerCount
                post["followers"] = followers
                
                // Set value and report transaction success
                currentData.value = post
                
                return FIRTransactionResult.successWithValue(currentData)
            }
            return FIRTransactionResult.successWithValue(currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        
        
        
    }
    
    func getInfo() {
        
        let userRef = firebaseRef.child("users").child(self.userUID)
        
        userRef.observeEventType(.Value, withBlock: { (snapshot) in
            if let userInfo = User(snapshot: snapshot) {
                self.followingLabel.text = "Following:\(userInfo.followCount)"
                self.followersLabel.text = "Followers:\(userInfo.followersCount)"
                self.postLabel.text = "Posts: \(userInfo.postCount)"
            }
        })
        
        userRef.child("uploaded").observeEventType(.Value, withBlock: { (Snapshot) in
            if let uploadedDict = Snapshot.value as? [String: Bool] {
                for (key, _) in uploadedDict {
                    self.firebaseRef.child("Images").child(key).observeSingleEventOfType(.ChildAdded, withBlock: { (uploadedSnapshot) in
                        let image = uploadedSnapshot.value as? String
                        self.userFeed.append(image!)
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
