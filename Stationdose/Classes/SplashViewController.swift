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
        
        // Do any additional setup after loading the view.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        moveToNextController()
        
    }
    
    func moveToNextController(){
        if (SpotifyManager.sharedInstance.hasSession){
            if (SpotifyManager.sharedInstance.hasValidSession){
                performSegueWithIdentifier(Constants.Segues.SplashToHomeSegue, sender: self)
            }else{
                SpotifyManager.sharedInstance.renewSession()
            }
        }else{
            performSegueWithIdentifier(Constants.Segues.SplashToLoginSegue, sender: self)
        }
    }
    
    func onSessionValid(notification:NSNotification){
        
        performSegueWithIdentifier(Constants.Segues.SplashToHomeSegue, sender: self)
        
        
    }
    
    func onSessionError(notification:NSNotification){
        
        
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
