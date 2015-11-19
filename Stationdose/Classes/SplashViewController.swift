//
//  SplashViewController.swift
//  Stationdose
//
//  Created by Developer on 11/16/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addFullBackground()
        
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
                moveToPremiumOrHome()
            } else {
                SpotifyManager.sharedInstance.renewSession()
                //moveToLogin()
            }
        }else{
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
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.performSegueWithIdentifier(Constants.Segues.SplashToRequestPremiumSegue, sender: self)
        }
        
    }
    
    func moveToHome(){
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.performSegueWithIdentifier(Constants.Segues.SplashToHomeSegue, sender: self)
        }
        
    }
    
    func moveToLogin(){
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.performSegueWithIdentifier(Constants.Segues.SplashToLoginSegue, sender: self)
        }
    }
    
    func onSessionError(notification:NSNotification){
        showErrorMessage("There was a problem while trying to login to Spotify. Please rety in a few minutes.")
    }

}
