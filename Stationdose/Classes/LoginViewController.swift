//
//  LoginViewController.swift
//  Stationdose
//
//  Created by Developer on 11/15/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        addFullBackground()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onSessionValid:", name: Constants.Notifications.sessionValidNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onSessionError:", name: Constants.Notifications.sessionErrorNotification, object: nil)
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    @IBAction func loginWithSpotify(sender: UIButton) {
        SpotifyManager.sharedInstance.openLogin()
    }
    
    func onSessionValid(notification:NSNotification){
        
        SpotifyManager.sharedInstance.checkPremium { isPremium in
            if isPremium{
                self.performSegueWithIdentifier(Constants.Segues.LoginToHomeSegue, sender: self)
            }else{
                self.performSegueWithIdentifier(Constants.Segues.LoginToRequestPremiumSegue, sender: self)
            }
        }
        
    }
    
    
    func onSessionError(notification:NSNotification){
        
        showErrorMessage("There was a problem while trying to login to Spotify. Please rety in a few minutes.")
        
    }
    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
