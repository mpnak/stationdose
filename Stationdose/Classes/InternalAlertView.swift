//
//  InternalAlertView.swift
//  Stationdose
//
//  Created by Developer on 11/26/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit

class InternalAlertView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var cancelButtonWidthLayoutConstraint: NSLayoutConstraint!
    
    class func instanceFromNib() -> InternalAlertView {
        return UINib(nibName: "InternalAlertView", bundle: nil).instantiateWithOwner(self, options: nil).first as! InternalAlertView
    }

}
