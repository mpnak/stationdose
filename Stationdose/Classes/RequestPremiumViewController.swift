//
//  RequestPremiumViewController.swift
//  Stationdose
//
//  Created by Developer on 11/17/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit

class RequestPremiumViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var timer:NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addFullBackground()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "checkPremium:", userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func checkPremium(timer:NSTimer) {
        SpotifyManager.sharedInstance.checkPremium { isPremium in
            if isPremium{
                self.activityIndicator.stopAnimating()
                timer.invalidate()
                self.performSegueWithIdentifier(Constants.Segues.RequestPremiumToHomeSegue, sender: self)
            }
        }
    }
    

    @IBAction func signUpPremium(sender: AnyObject) {
        activityIndicator.startAnimating()
        performSegueWithIdentifier(Constants.Segues.RequestPremiumToRequestPremiumWebSegue, sender: self)
    }

}
