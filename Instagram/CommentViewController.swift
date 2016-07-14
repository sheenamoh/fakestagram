//
//  CommentViewController.swift
//  Instagram
//
//  Created by Skkz on 11/07/2016.
//  Copyright © 2016 Skkz. All rights reserved.
//

import UIKit
import Firebase

class CommentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var userName = String()
    var imageKey = String()
//    var userList = [String]()
//    var commentList = [String]()
    var feedOfComments = [Comment]()
    var image: Image!
    var firebaseRef = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getCommentInfo()
        self.tableView.reloadData()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func enterBtn(sender: UIButton) {
        let commentRef = self.firebaseRef.child("Comments").child(image.key).childByAutoId()
        guard commentTextField.text != nil else {
            return
        }
        
        let username = self.userName
        guard let currentUserUID = User.currentUserUid(), let comment = commentTextField.text else {
            return
        }
        
        let commentDict = ["userID": currentUserUID, "userName": username, "comment": comment]
        commentRef.setValue(commentDict)
        
            self.tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("commentlistcell")!
        let comment = feedOfComments[indexPath.row]
        cell.textLabel?.text = comment.comment
        cell.detailTextLabel?.text = comment.userName

        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedOfComments.count
    }
    
    
    
    func getCommentInfo() {
        
        let commentRef = firebaseRef.child("Comments").child(image.key)
        
        commentRef.observeEventType(.ChildAdded, withBlock: {(snapshot) in
            if let comment = Comment(snapshot: snapshot) {
                self.feedOfComments.append(comment)
            }
        })
        
        let userRef = firebaseRef.child("users").child(User.currentUserUid()!)
        
        userRef.observeSingleEventOfType(.Value, withBlock:  { (snapshot) in
            if let userInfo = User(snapshot: snapshot) {
                self.userName = userInfo.userName
                self.tableView.reloadData()
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
