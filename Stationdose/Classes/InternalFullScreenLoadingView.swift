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

        radioActivityIndicator = NVActivityIndicatorView(frame: activityIndicatoer.frame, type: .LineScale, color:UIColor.customSectionDividersColor())
        addSubview(radioActivityIndicator)
        radioActivityIndicator.startAnimation()
        
    }


}
