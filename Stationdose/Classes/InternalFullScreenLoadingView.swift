//
//  InternalFullScreenLoadingView.swift
//  Stationdose
//
//  Created by Developer on 12/10/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class InternalFullScreenLoadingView: UIView {

    @IBOutlet weak var activityIndicatoer: UIActivityIndicatorView!
    var radioActivityIndicator:NVActivityIndicatorView!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        activityIndicatoer.hidden = true
    }
    
    class func instanceFromNib() -> InternalFullScreenLoadingView {
        return UINib(nibName: "InternalFullScreenLoadingView", bundle: nil).instantiateWithOwner(self, options: nil).first as! InternalFullScreenLoadingView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        
        if radioActivityIndicator == nil {
            
            let indy = NVActivityIndicatorView(frame: CGRectMake(0, 0, 35, 35), type: .LineScale, color:UIColor.customSectionDividersColor())
            indy.center = activityIndicatoer.center
            
            radioActivityIndicator = indy
            addSubview(radioActivityIndicator)
            radioActivityIndicator.startAnimation()
        }
    }
}
