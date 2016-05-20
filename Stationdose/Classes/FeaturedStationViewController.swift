//
//  FeaturedStationViewController.swift
//  Stationdose
//
//  Created by Developer on 12/3/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit

class FeaturedStationViewController: PlaylistBaseViewController {
    
    @IBOutlet weak var sponsoredTitleView: UIView!
    @IBOutlet weak var featuredTitleView: UIView!
    @IBOutlet weak var stationDetailsLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionViewHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var coverImageViewHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var urlButtonOutlet: UIButton!
//    @IBAction func urlButton(sender: UIButton) {
//        if station?.type == "featured"{
//            
//        }else{
//            var url : NSURL
//            url = (urlLabel.text!.containsString("https://") ? NSURL(string: urlLabel.text!) : NSURL(string: "https://" + urlLabel.text!))!
//            //url = NSURL(string: "https://" + urlLabel.text!)!
//            UIApplication.sharedApplication().openURL(url)
//            
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if station?.type == "featured" {
            descriptionLabel.text = station?.shortDescription
            descriptionViewHeightLayoutConstraint.constant = 300 //Any large number is ok
            coverImageViewHeightLayoutConstraint.constant = 160
            featuredTitleView.alpha = 1
            sponsoredTitleView.alpha = 0
        } else { //sponsored
            descriptionViewHeightLayoutConstraint.constant = 0
            coverImageViewHeightLayoutConstraint.constant = 110
            featuredTitleView.alpha = 0
            sponsoredTitleView.alpha = 1
            //urlButtonOutlet.userInteractionEnabled = true
        }
    }

}
