//
//  FeedTableViewController.swift
//  Instagram
//
//  Created by Skkz on 05/07/2016.
//  Copyright © 2016 Skkz. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class FeedTableViewController: UITableViewController {
    
    var feedofImages = [Image]()
    //    var countLikes = [Int]()
    var photosUID = [String]()
    var currentUserName: String!
    var listofComments = [String]()
    var usersSet = Set <String>()
    let firebaseRef = FIRDatabase.database().reference()
    let storageRef = FIRStorage.storage().referenceForURL("gs://fakestagram-8cb01.appspot.com/images")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageAppending()
        //        photosInfo()
        //        checkProfile()
        //        getLikesCount()
        //        getComments()
        
        self.title = "Instagram"
        //        tableView.estimatedRowHeight = 500
        //        tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.reloadData()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    // MARK: - Table view data source
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (feedofImages.count)*2
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row % 2 == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("Infocell", forIndexPath: indexPath) as! ImageTableViewCell
                let image = feedofImages[(indexPath.row)]
                let url = NSURL(string: image.imageURL)
                cell.postedImage.sd_setImageWithURL(url)
                if let user = image.user {
                    cell.userName.setTitle(user.userName, forState: .Normal)
                }
                cell.likeLabel.text = String(image.likesCount)
                cell.delegate = self
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("Infocell", forIndexPath: indexPath) as! ImageTableViewCell
                let image = feedofImages[(indexPath.row)/2]
                let url = NSURL(string: image.imageURL)
                cell.postedImage.sd_setImageWithURL(url)
                if let user = image.user {
                    cell.userName.setTitle(user.userName, forState: .Normal)
                }
                cell.likeLabel.text = String(image.likesCount)
                cell.delegate = self
                return cell
            }
            
        } else {
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "commentcell")
            //            if self.listofComments[(listofComments.count)-1] != "" {
            ////                cell.textLabel?.text = self.listofComments[(listofComments.count)-1]
            //            }else {
            //                cell.textLabel!.text = "no comments"
            //            }
            return cell
        }
    }
    
    
    @IBAction func likeAction(sender: UIButton) {
        let image = self.feedofImages[sender.tag]
        let imageRef = self.firebaseRef.child("Images").child(image.key)
        
        imageRef.runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            if var post = currentData.value as? [String : AnyObject], let uid = User.currentUserUid() {
                var likes : Dictionary<String, Bool>
                likes = post["likes"] as? [String : Bool] ?? [:]
                var likesCount = post["likesCount"] as? Int ?? 0
                if let _ = likes[uid] {
                    // Unstar the post and remove self from stars
                    likesCount -= 1
                    likes.removeValueForKey(uid)
                    dispatch_async(dispatch_get_main_queue(), {
                        sender.setImage(UIImage(named: "love"), forState: .Normal)
                    })
                    
                } else {
                    // Star the post and add self to stars
                    likesCount += 1
                    likes[uid] = true
                    dispatch_async(dispatch_get_main_queue(), {
                        sender.setImage(UIImage(named: "red"), forState: .Normal)
                    })
                }
                post["likesCount"] = likesCount
                post["likes"] = likes
                
                // Set value and report transaction success
                currentData.value = post
                image.likesCount = likesCount
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
                
                
                return FIRTransactionResult.successWithValue(currentData)
            }
            return FIRTransactionResult.successWithValue(currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func imageAppending() {
        
        let userRef = firebaseRef.child("users").child(User.currentUserUid()!).child("following") 
        
        self.usersSet.insert(User.currentUserUid()!)
        
        userRef.observeEventType(.Value, withBlock:  { (Snapshot) in
            if let followingDict = Snapshot.value as? [String: Bool] {
                for (key, value) in followingDict {
                    self.firebaseRef.child("users").child(User.currentUserUid()!).child("following").observeSingleEventOfType(.ChildAdded, withBlock: { (followingSnapshot) in
                        let following = followingSnapshot.key as? String
                        self.usersSet.insert(following!)
                        print(self.usersSet)
                    })
                }
                
            }
        })
        
        let imageRef = firebaseRef.child("Images")
        imageRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            if let image = Image(snapshot: snapshot){
                
                if self.usersSet.contains(image.userUID) {
                    
                    self.feedofImages.append(image)
                    self.firebaseRef.child("users").child(image.userUID).observeSingleEventOfType(.Value, withBlock: { (userSnapshot) in
                        if let user = User(snapshot: userSnapshot){
                            image.user = user
                            self.tableView.reloadData()
                        }
                        
                    })
                }
            }
        })
    }
    
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row % 2 == 0 {
            return 386
        }
        else {
            return 40
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "commentsegue" {
            let dest: CommentViewController = segue.destinationViewController as! CommentViewController
            if let cell = sender as? ImageTableViewCell {
                let indexPath = self.tableView.indexPathForCell(cell)
                dest.title = "Comments Section"
                //                    dest.photosUID = self.photosUID[(indexPath!.row)]
                
                if indexPath!.row % 2 == 0 {
                    if indexPath!.row == 0 {
                        dest.image = self.feedofImages[(indexPath?.row)!]
                    } else {
                        dest.image = self.feedofImages[(indexPath?.row)!/2]
                    }
                }
                
                print(indexPath!.row)
            }
        }
            
        else
            if segue.identifier == "usersegue" {
                let dest: UserViewController = segue.destinationViewController as! UserViewController
                if let cell = sender as? ImageTableViewCell {
                    let indexPath = self.tableView.indexPathForCell(cell)
                    dest.title = sender?.title
                    
                    if indexPath!.row % 2 == 0 {
                        if indexPath!.row == 0 {
                            //asd
                        }
                        else {
                            //baca
                        }
                    }
                }
        }
    }
    
    
}

extension FeedTableViewController: ImageTableViewCellDelegate {
    
    func commentBtnTapped(cell: ImageTableViewCell) {
        self.performSegueWithIdentifier("commentsegue", sender: cell)
    }
    
    func likeBtnTapped(cell: ImageTableViewCell) {
        print("Like button Tapped!")
    }
    
    func userNameBtnTapped(cell: ImageTableViewCell) {
        self.performSegueWithIdentifier("usersegue", sender: cell)
    }
    
}
