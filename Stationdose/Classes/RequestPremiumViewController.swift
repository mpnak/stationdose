//
//  RequestPremiumViewController.swift
//  Stationdose
//
//  Created by Developer on 11/17/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit

class RequestPremiumViewController: UIViewController {
    
    
    private var timer:NSTimer?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        timer = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: "checkPremium:", userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func checkPremium(timer:NSTimer){
        SpotifyManager.sharedInstance.checkPremium { isPremium in
            if isPremium{
                timer.invalidate()
                self.performSegueWithIdentifier(Constants.Segues.RequestPremiumToHomeSegue, sender: self)
            }
        }
    }
    

    @IBAction func signUpPremium(sender: AnyObject) {
        performSegueWithIdentifier(Constants.Segues.RequestPremiumToRequestPremiumWebSegue, sender: self)
    }

}
