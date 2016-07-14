//
//  ImageTableViewCell.swift
//  Instagram
//
//  Created by Skkz on 11/07/2016.
//  Copyright © 2016 Skkz. All rights reserved.
//

import UIKit
import Firebase
protocol ImageTableViewCellDelegate {
    
    func likeBtnTapped(cell: ImageTableViewCell)
    func commentBtnTapped(cell: ImageTableViewCell)
    func userNameBtnTapped(cell: ImageTableViewCell)
    
}

class ImageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var commentsBtn: UIButton!
    var likeRef = FIRDatabase.database().reference().child("Images").child("likes")
    var delegate: ImageTableViewCellDelegate?
    
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var postedImage: UIImageView!
    
    @IBOutlet weak var userName: UIButton!
    @IBAction func likeBtnClicked(sender: UIButton) {
        //flip image
        
    delegate?.likeBtnTapped(self)

//        if let _ = (likeRef.queryEqualToValue(User.currentUserUid())) {
//            sender.imageView?.transform =
//            sender.setImage(UIImage(named: "red"), forState: .Selected)
//        } else {
//            sender.imageView?.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
//            sender.setImage(UIImage(named: "love"), forState: .Highlighted)
//        }
    }
    
    
    @IBAction func commentBtnClicked(sender: UIButton) {
        
        delegate?.commentBtnTapped(self)
    }
    
    @IBAction func userNameBtnClicked(sender: UIButton) {
        
        delegate?.userNameBtnTapped(self)
    }
    

}
