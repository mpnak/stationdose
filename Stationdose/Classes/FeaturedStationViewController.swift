//
//  FeaturedStationViewController.swift
//  Stationdose
//
//  Created by Developer on 12/3/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit

class FeaturedStationViewController: PlaylistViewController {
    
    @IBOutlet weak var sponsoredTitleView: UIView!
    @IBOutlet weak var featuredTitleView: UIView!
    @IBOutlet weak var stationDetailsLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionViewHeightLayoutConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showUserProfileButton = true;
        
        if station?.type == "featured" {
            descriptionLabel.text = station?.shortDescription
            descriptionViewHeightLayoutConstraint.constant = 300 //Any large number is ok
            featuredTitleView.alpha = 1
            sponsoredTitleView.alpha = 0
        } else { //sponsored
            descriptionViewHeightLayoutConstraint.constant = 0
            featuredTitleView.alpha = 0
            sponsoredTitleView.alpha = 1
        }
        
    }
}
