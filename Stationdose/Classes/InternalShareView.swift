//
//  InternalShareView.swift
//  Stationdose
//
//  Created by Developer on 12/21/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit

class InternalShareView: UIView {
    
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var createPlaylistButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    class func instanceFromNib() -> InternalShareView {
        let instance = UINib(nibName: "InternalShareView", bundle: nil).instantiateWithOwner(self, options: nil).first as! InternalShareView
        
        instance.facebookButton.contentHorizontalAlignment = .Left;
        instance.twitterButton.contentHorizontalAlignment = .Left;
        instance.emailButton.contentHorizontalAlignment = .Left;
        
        return instance
    }

}
