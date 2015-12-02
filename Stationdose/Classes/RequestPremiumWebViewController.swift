//
//  RequestPremiumWebViewController.swift
//  Stationdose
//
//  Created by Developer on 11/17/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit

class RequestPremiumWebViewController: UIViewController {
    @IBOutlet weak var webView: UIWebView!
    
    private var timer:NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.loadRequest(NSURLRequest(URL: Constants.Spotify.GoPremiumUrl!))
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "checkPremium:", userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    @IBAction func done(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func checkPremium(timer:NSTimer) {
        SpotifyManager.sharedInstance.checkPremium { isPremium in
            if isPremium{
                timer.invalidate()
                self.performSegueWithIdentifier(Constants.Segues.RequestPremiumToHomeSegue, sender: self)
            }
        }
    }

}
