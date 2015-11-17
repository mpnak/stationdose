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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.loadRequest(NSURLRequest(URL: Constants.Spotify.GoPremiumUrl!))

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func done(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
