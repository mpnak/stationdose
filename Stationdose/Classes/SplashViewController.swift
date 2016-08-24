//
//  SplashViewController.swift
//  Stationdose
//
//  Created by Developer on 11/16/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Darwin


class SplashViewController: UIViewController, SpotifyManagerLoginDelegate {
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private var transitionManager: TransitionManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.setNeedsLayout()
        activityIndicator.layoutIfNeeded()
        
        let activityIndicatorView = NVActivityIndicatorView(frame: CGRectMake(0, 0, 40, 40), type: .LineScale, color:UIColor.customSectionDividersColor())
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.center = activityIndicator.center
        activityIndicatorView.startAnimation()
        
        addFullBackground()
        
        transitionManager = TransitionManager(transition: .Fade)
        transitioningDelegate = transitionManager
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if (SpotifyManager.sharedInstance.hasSession) {
            SpotifyManager.sharedInstance.loginWithExistingSession(self)
        } else {
            self.performSegueWithIdentifier(Constants.Segues.SplashToLoginSegue, sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        segue.destinationViewController.transitioningDelegate = transitionManager
    }

    // Mark: - SpotifyManagerLoginDelegate
    
    func loginAcountNeedsPremium() {
        self.performSegueWithIdentifier(Constants.Segues.SplashToRequestPremiumSegue, sender: self)
    }
    
    func loginSuccess() {
            self.performSegueWithIdentifier(Constants.Segues.SplashToHomeSegue, sender: self)
    }
    
    func loginFailure(error: NSError?) {
        self.performSegueWithIdentifier(Constants.Segues.SplashToLoginSegue, sender: self)
    }
    
    func loginCancelled() {}
}
