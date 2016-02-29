//
//  LoginViewController.swift
//  Stationdose
//
//  Created by Developer on 11/15/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class LoginViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var radioActivityIndicator:NVActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addFullBackground()
        activityIndicator.setNeedsLayout()
        activityIndicator.layoutIfNeeded()
        activityIndicator.hidden = true
        radioActivityIndicator = NVActivityIndicatorView(frame: activityIndicator.frame, type: .LineScale, color:UIColor.customSectionDividersColor())
        self.view.addSubview(radioActivityIndicator)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onSessionValid:", name: Constants.Notifications.sessionValidNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onSessionError:", name: Constants.Notifications.sessionErrorNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @IBAction func loginWithSpotify(sender: UIButton) {
        SpotifyManager.sharedInstance.openLogin(self)
        loginButton.hidden = true
        //self.activityIndicator.startAnimating()
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
    
    func onSessionValid(notification:NSNotification){
        SpotifyManager.sharedInstance.checkPremium { isPremium in
            if isPremium {
                ModelManager.sharedInstance.initialCache { () -> Void in
                    //self.activityIndicator.stopAnimating()
                    self.radioActivityIndicator.stopAnimation()
                    self.loginButton.hidden = false
                    self.performSegueWithIdentifier(Constants.Segues.LoginToHomeSegue, sender: self)
                }
            } else {
                //self.activityIndicator.stopAnimating()
                self.radioActivityIndicator.stopAnimation()
                self.loginButton.hidden = false
                self.performSegueWithIdentifier(Constants.Segues.LoginToRequestPremiumSegue, sender: self)
            }
        }
    }
    
    func onSessionError(notification:NSNotification){
        self.loginButton.hidden = false
        showGenericErrorMessage()
    }
}
