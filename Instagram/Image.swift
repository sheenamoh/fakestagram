//
//  Image.swift
//  Instagram
//
//  Created by Skkz on 13/07/2016.
//  Copyright © 2016 Skkz. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Image{
    let key: String
    let imageURL: String
    var likesUID: [String: Bool]
    var likesCount: Int
    var userUID: String
    var commentID: [String: Bool]
    
    var user: User?
    var comment: Comment?
    
    init?(snapshot: FIRDataSnapshot){
        guard let imageDict = snapshot.value as? [String: AnyObject] else{
            return nil
        }
        
        key = snapshot.key
        imageURL = imageDict["imageURL"] as! String
        userUID = imageDict["userID"] as! String

        
        if let likesUID = imageDict["likes"] as? [String: Bool]{
            self.likesUID = likesUID
        }else{
            self.likesUID = [:]
        }
        
        if let likesCount = imageDict["likesCount"] as? Int {
            self.likesCount = likesCount
        }else{
            self.likesCount = 0
        }
        
        if let commentUID = imageDict["commentID"] as? [String: Bool] {
            self.commentID = commentUID
        } else {
            self.commentID = [:]
        }
        
    }
}