//
//  Comment.swift
//  Instagram
//
//  Created by Skkz on 13/07/2016.
//  Copyright © 2016 Skkz. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Comment {
    let key: String
    var userName: String
    var userUID: String
    var comment: String
    
    var user: User?
    
    init?(snapshot: FIRDataSnapshot){
        guard let commentDict = snapshot.value as? [String:AnyObject] else {
            return nil
        }
        
        key = snapshot.key
        
        if let FBusername = commentDict["userName"] as? String {
            self.userName = FBusername
        } else {
            self.userName = ""
        }
        
        if let FBuserUID = commentDict["userID"] as? String {
            self.userUID = FBuserUID
        } else {
            self.userUID = ""
        }
        
        if let userComment = commentDict["comment"] as? String {
            self.comment = userComment
        } else {
            self.comment = ""
        }
        
    }
    
}