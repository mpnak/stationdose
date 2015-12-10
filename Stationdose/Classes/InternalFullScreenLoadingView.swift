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

    
    override func awakeFromNib() {
        activityIndicatoer.setNeedsLayout()
        activityIndicatoer.layoutIfNeeded()
        activityIndicatoer.hidden = true
        radioActivityIndicator = NVActivityIndicatorView(frame: activityIndicatoer.frame, type: .LineScale, color:UIColor.customSpotifyGreenColor())
        addSubview(radioActivityIndicator)
        radioActivityIndicator.startAnimation()
    }
    
    class func instanceFromNib() -> InternalFullScreenLoadingView {
        return UINib(nibName: "InternalFullScreenLoadingView", bundle: nil).instantiateWithOwner(self, options: nil).first as! InternalFullScreenLoadingView
    }


}
