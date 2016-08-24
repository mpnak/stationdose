//
//  LoginViewController.swift
//  Stationdose
//
//  Created by Developer on 11/15/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class LoginViewController: UIViewController, SpotifyManagerLoginDelegate {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var radioActivityIndicator: NVActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addFullBackground()
        activityIndicator.setNeedsLayout()
        activityIndicator.layoutIfNeeded()
        activityIndicator.hidden = true
        radioActivityIndicator = NVActivityIndicatorView(frame: activityIndicator.frame, type: .LineScale, color:UIColor.customSectionDividersColor())
        self.view.addSubview(radioActivityIndicator)
    }
    
    @IBAction func loginWithSpotify(sender: UIButton) {
        SpotifyManager.sharedInstance.openLogin(self)
        loginButton.hidden = true
        radioActivityIndicator.startAnimation()
        sender.borderColor = UIColor.customButtonBorderColor()
    }
    
    @IBAction func loginWithSpotifyTouchDragExit(sender: UIButton) {
        sender.borderColor = UIColor.customButtonBorderColor()
    }
    
    @IBAction func loginWithSpotifyTouchDragEnter(sender: UIButton) {
        sender.borderColor = UIColor.customButtonBorderTapColor()
    }
    
    @IBAction func loginWithSpotifyTouchDown(sender: UIButton) {
        sender.borderColor = UIColor.customButtonBorderTapColor()
    }
    
    // Mark: - SpotifyManagerLoginDelegate
    
    func loginAcountNeedsPremium() {
        self.performSegueWithIdentifier(Constants.Segues.LoginToRequestPremiumSegue, sender: self)
        self.radioActivityIndicator.stopAnimation()
        self.loginButton.hidden = false
    }
    
    func loginSuccess() {
        //ModelManager.sharedInstance.initialCache { () -> Void in
            //self.activityIndicator.stopAnimating()
            self.radioActivityIndicator.stopAnimation()
            self.loginButton.hidden = false
            self.performSegueWithIdentifier(Constants.Segues.LoginToHomeSegue, sender: self)
        //}
    }
    
    func loginFailure(error: NSError?) {
        self.loginButton.hidden = false
        self.radioActivityIndicator.stopAnimation()
        showGenericErrorMessage()
    }
    
    func loginCancelled() {
        self.loginButton.hidden = false
        self.radioActivityIndicator.stopAnimation()
    }
}
