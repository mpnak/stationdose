//
//  SplashViewController.swift
//  Stationdose
//
//  Created by Developer on 11/16/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit
import NVActivityIndicatorView


class SplashViewController: UIViewController {
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private var transitionManager: TransitionManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.setNeedsLayout()
        activityIndicator.layoutIfNeeded()
        
        let activityIndicatorView = NVActivityIndicatorView(frame: activityIndicator.frame, type: .LineScale, color:UIColor.customSpotifyGreenColor())
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimation()
        
        addFullBackground()
        
        transitionManager = TransitionManager(transition: .Fade)
        transitioningDelegate = transitionManager
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onSessionValid:", name: Constants.Notifications.sessionValidNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onSessionError:", name: Constants.Notifications.sessionErrorNotification, object: nil)
    
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        moveToNextController()
        
    }
    
    func moveToNextController(){
        if (SpotifyManager.sharedInstance.hasSession) {
            if (SpotifyManager.sharedInstance.hasValidSession) {
                //moveToPremiumOrHome()
                SpotifyManager.sharedInstance.renewSession()
            } else {
                SpotifyManager.sharedInstance.renewSession()
                //moveToLogin()
            }
        }else{
            NSNotificationCenter.defaultCenter().removeObserver(self)
            moveToLogin()
        }
    }

    
    func onSessionValid(notification:NSNotification){
        
        moveToPremiumOrHome()
    }
    
    func moveToPremiumOrHome(){
        SpotifyManager.sharedInstance.checkPremium { isPremium in
            if isPremium{
                self.moveToHome()
            }else{
                self.moveToRequestPremium()
            }
        }
    }
    
    func moveToRequestPremium(){
        self.performSegueWithIdentifier(Constants.Segues.SplashToRequestPremiumSegue, sender: self)
        
    }
    
    func moveToHome(){
        
        ModelManager.sharedInstance.initialCache { () -> Void in
            self.performSegueWithIdentifier(Constants.Segues.SplashToHomeSegue, sender: self)
        }
        
    }
    
    func moveToLogin(){
        self.performSegueWithIdentifier(Constants.Segues.SplashToLoginSegue, sender: self)
    }
    
    func onSessionError(notification:NSNotification){
        showGenericErrorMessage()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        segue.destinationViewController.transitioningDelegate = transitionManager
    }

}
