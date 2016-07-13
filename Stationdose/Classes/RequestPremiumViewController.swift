//
//  RequestPremiumViewController.swift
//  Stationdose
//
//  Created by Developer on 11/17/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SafariServices

class RequestPremiumViewController: UIViewController, SFSafariViewControllerDelegate {
    
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
        SpotifyManager.sharedInstance.logout()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        //timer?.invalidate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func backButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func signUpPremium(sender: AnyObject) {
        activityIndicator.startAnimating()
        //radioActivityIndicator.stopAnimation()
        
        let sfVC = SFSafariViewController(URL: Constants.Spotify.GoPremiumUrl!)
        sfVC.delegate = self
        
        presentViewController(sfVC, animated: true, completion: nil)
    }
    
    
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        SpotifyManager.sharedInstance.logout()
        dismissViewControllerAnimated(true, completion: nil)
    }

}
