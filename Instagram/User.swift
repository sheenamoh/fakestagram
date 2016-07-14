//
//  User.swift
//  Instagram
//
//  Created by Skkz on 05/07/2016.
//  Copyright © 2016 Skkz. All rights reserved.
//

import UIKit
import FirebaseDatabase

class User: NSObject {
    var followers: [String: Bool]
    var followersCount: Int
    var key: String
    var following: [String: Bool]
    var followCount: Int
    var uploaded: [String: Bool]
    var postCount: Int
    var userName: String
    
    init?(snapshot: FIRDataSnapshot) {
        guard let dict = snapshot.value as? [String: AnyObject] else {
            return nil
        }
        key = snapshot.key
        
        if let FBfollowers = dict["followers"] as? [String: Bool] {
            self.followers = FBfollowers
        } else {
            self.followers = [:]
        }
        
        if let FBfollowersCount = dict["followerCount"] as? Int {
            self.followersCount = FBfollowersCount
        } else {
            self.followersCount = 0
        }
        
        if let FBfollowing = dict["following"] as? [String: Bool] {
            self.following = FBfollowing
        } else {
            self.following = [:]
        }
        
        if let FBfollowCount = dict["followCount"] as? Int {
            self.followCount = FBfollowCount
        } else {
            self.followCount = 0
        }
        
        if let FBuploaded = dict["uploaded"] as? [String: Bool] {
            self.uploaded = FBuploaded
        } else {
            self.uploaded = [:]
        }
        
        if let FBpostCount = dict["postCount"] as? Int {
            self.postCount = FBpostCount
        } else {
            self.postCount = 0
        }
        
        if let name = dict["username"] as? String {
            self.userName = name
        } else {
            self.userName = ""
        }
        
    }
    
    
    
    class func signIn (uid: String) {
        NSUserDefaults.standardUserDefaults().setValue(uid, forKeyPath: "uid")
    }
    
    class func isSignedIn() -> Bool{
        if let _ = NSUserDefaults.standardUserDefaults().valueForKey("uid") as? String {
            return true
            
        }else{
            return false
        }
    }
    
    class func currentUserUid() -> String?{
        return NSUserDefaults.standardUserDefaults().valueForKey("uid") as? String
    }
    
    class func removeUserUid() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("uid")
    }

}
