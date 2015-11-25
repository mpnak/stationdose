//
//  HomeViewController.swift
//  Stationdose
//
//  Created by Developer on 11/15/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit
import CoreLocation

class HomeViewController: BaseViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var featuresStationsPageControl: UIPageControl!
    @IBOutlet weak var stationsSegmentedControl: UISegmentedControl!
    @IBOutlet weak var myStationsEmptyView: UIView!
    
    private var location:CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.showLogo = true;
        showUserProfileButton = true;
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        LocationManager.sharedInstance.getCurrentLocation(self) { (location, error) -> () in
            self.location = location
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth)+1)
        featuresStationsPageControl.currentPage = page
    }
    
    @IBAction func stationsSegmentedControlValueChanged(sender: UISegmentedControl) {
        var myStationsEmptyViewVisible = false
        
        switch stationsSegmentedControl.selectedSegmentIndex {
        case 0:
            myStationsEmptyViewVisible = true
        case 1:
            myStationsEmptyViewVisible = false
        default: break
        }
        
        UIView.animateWithDuration(0.1) { () -> Void in
            self.myStationsEmptyView.alpha = myStationsEmptyViewVisible ? 1 : 0
        }
    }
    
    @IBAction func addStations(sender: AnyObject) {
        stationsSegmentedControl.selectedSegmentIndex = 1;
        stationsSegmentedControlValueChanged(stationsSegmentedControl)
    }
    
}
