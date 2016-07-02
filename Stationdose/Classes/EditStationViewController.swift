//
//  EditStationViewController.swift
//  Stationdose
//
//  Created by Washington Miranda on 12/16/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit
import Foundation

class EditStationViewController: BaseViewController, DetailsPageScrollDelegate {
    
    var station: Station?
    
    @IBOutlet weak internal var coverImageView: UIImageView!
    @IBOutlet weak internal var nameLabel: UILabel!
    @IBOutlet weak var updatedAtLabel: UILabel!
    @IBOutlet weak var familiarityOutlet: UIView!
    @IBOutlet weak var shortDescriptionLabel: UILabel!
    @IBOutlet weak var familiaritySlider: UISlider!
    @IBOutlet weak var getPlaylistButton: UIButton!
    
    private let fullscreenView = FullScreenLoadingView()
    private var somethingChanged: Bool = false
    
    var energyChartViewPageScrollController: PageScrollViewController?
    var weatherSideScrollerViewController: WeatherSideScrollerViewController?
    var recommendedSideScrollerViewController: RecommendedSideScrollerViewController?
    
    var defaultProfile: String = ""
    var currentProfile: String = ""
    var profiles = [String]()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let nav = self.navigationController as? MainNavigationController {
            nav.hideLoading()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "btn-back"), style: .Plain, target: self, action: #selector(UIViewController.back))
        
        //NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(EditStationViewController.stationDidChangeUpdatedAt(_:)), name: SongSortApiManagerNotificationKey.StationDidChangeUpdatedAt.rawValue, object: nil)
        
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0)))
        familiarityOutlet.hidden = false
        nameLabel?.text = station?.name
        shortDescriptionLabel?.text = station?.shortDescription
        updatedAtLabel?.text = station?.updatedAtString()
        
        if let imageUrl = station?.art {
            let url = NSURL(string: imageUrl)!
            print(imageUrl)
            coverImageView?.af_setImageWithURL(url, placeholderImage: UIImage(named: "station-placeholder"))
        } else {
            coverImageView.image = UIImage(named: "station-placeholder")
        }
        
        setupFamiliaritySlider()
        
        if let station = station {
            
            let title = UILabel(frame: self.navigationController!.navigationBar.frame)
            title.textColor = .whiteColor()
            title.textAlignment = NSTextAlignment.Center
            title.text = station.name
            title.sizeToFit()
            self.navigationItem.titleView = title
            
            if station.undergroundness == nil {
                station.undergroundness = 4
            }
            familiaritySlider.value = familiaritySliderValueMapInverse(station.undergroundness!)
            
            SongSortApiManager.sharedInstance.getPlaylistProfiles { (profileChooser, error) in
                print("error: \(error)")
                print("PROFILE: \(profileChooser?.name)")
                
//                station.playlistProfileChooser = profileChooser
                self.profiles = profileChooser!.all_names!
                
                for i in 0..<self.profiles.count {
                    if profileChooser?.name == self.profiles[i] {
                        self.defaultProfile = self.profiles[i]
                        self.currentProfile = self.profiles[i]
                        self.energyChartViewPageScrollController?.defaultPlaylistIndex = i
                        break
                    }
                }
                let weather = profileChooser?.weather
                let time = profileChooser?.localtime
                if self.weatherSideScrollerViewController != nil {
                    self.weatherSideScrollerViewController!.setConditions(defaultIndex: self.energyChartViewPageScrollController!.defaultPlaylistIndex, weather: weather, time: time, forParentScrollView: self.energyChartViewPageScrollController!.scrollView!)
                }
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParentViewController() {
            if station?.tracks == nil {
                if let nav = self.navigationController as? MainNavigationController {
                    nav.showLoading()
                }
                self.navigationController?.popToRootViewControllerAnimated(true)
            }
        }
    }
    
    @IBAction func nextPressed (sender: AnyObject?) {
        if energyChartViewPageScrollController!.currentPageIndex + 1 <= energyChartViewPageScrollController!.myViews.count-1 {
            energyChartViewPageScrollController?.advanceNext()
        }
    }
    
    @IBAction func prevPressed (sender: AnyObject?) {
        if energyChartViewPageScrollController!.currentPageIndex >= 1 {
            energyChartViewPageScrollController?.advancePrev()
        }
    }
    
    func detailsScrollViewSetIndex(defaultIndex: Int) {
        weatherSideScrollerViewController?.setDefaultIndex(defaultIndex, forParentScrollView: energyChartViewPageScrollController!.scrollView!)
        recommendedSideScrollerViewController?.setDefaultIndex(defaultIndex, forParentScrollView: energyChartViewPageScrollController!.scrollView!)
    }
    
//    func detailsScrollViewScrollingfromIndex(fromIndex: Int, toIndex: Int, direction: Int, withOffsetProportion: CGFloat) {
//        sideScrollerViewController?.scrollingFromIndex(fromIndex, toIndex: toIndex, direction: direction, withOffsetProportion: withOffsetProportion)
//    }
    
    func detailsScrollViewDidPage(scrollView: UIScrollView, pageIndex: Int) {
        weatherSideScrollerViewController?.scrollViewDidPage(scrollView, pageIndex: pageIndex)
        currentProfile = profiles[pageIndex]
        
    }
    
    func detailsScrollViewShouldScroll(scrollView: UIScrollView, withPrevPageIndex: Int, current: Int, next: Int) {
        print("delegate")
    }
    
//    deinit {
//        NSNotificationCenter.defaultCenter().removeObserver(self)
//    }
    
//    func stationDidChangeUpdatedAt(notification: NSNotification) {
//        if let station = notification.object as? Station {
//            if station.id == self.station?.id {
//                updatedAtLabel?.text = station.updatedAtString()
//            }
//        }
//    }
    
//    @IBAction func weatherInfoAction(sender: AnyObject) {
//        AlertView(title: "Local weather", message: "Stationdose looks at your local weather conditions and adjusts your station accordingly. Rainy? Probably be a bit more mellow. Sunny? Expect your station to have a bit more bounce in its step.", acceptButtonTitle: "Cool", cancelButtonTitle: nil) { (_) -> Void in }.show()
//    }
//    
//    @IBAction func timeInfoAction(sender: AnyObject) {
//        AlertView(title: "Time of day", message: "Similar to using the weather to push your playlist a certain way, adding time of day will only amplify the effect. Rainy Monday morning? Gonna be a properly mellow playlist. Rainy Friday afternoon? Well we take one part rainy, add two parts Friday, a half-tablespoon of afternoon, and whip up a rocktail that won’t dissapoint. Served with a twist of lime.", acceptButtonTitle: "Cool", cancelButtonTitle: nil) { (_) -> Void in }.show()
//    }
    
    @IBAction func energyProfileInfoAction(sender: AnyObject) {
        AlertView(title: "Energy Profile", message: "Playlist Profiles showing more blue in the graph will feature lower energy music while profiles with more red will feature more upbeat tracks. Based on day of the week, time of day and weather, Stationdose recommends a profile we think will suit. Of course you can always adjust it up and down to better suit your mood.", acceptButtonTitle: "Cool", cancelButtonTitle: nil) { (_) -> Void in }.show()
    }
    
    @IBAction func basedOnInfoAction(sender: AnyObject) {
        AlertView(title: "Based On", message: "Stationdose looks at the day of the week, time of day, and local weather conditions to select a vibe for your playlist. Early Monday morning we’ll recommend a more mellow playlist while Friday afternoon we think you’ll like it more upbeat.", acceptButtonTitle: "Cool", cancelButtonTitle: nil) { (_) -> Void in }.show()
    }
    
    @IBAction func familiarityInfoAction(sender: AnyObject) {
        AlertView(title: "Familiarity", message: "For a playlist with songs you’re more likely to know, move the slider left. For a playlist with songs you might not have heard before, move it right. For a little bit of both keep it in the middle.", acceptButtonTitle: "Cool", cancelButtonTitle: nil) { (_) -> Void in }.show()
    }
    
    @IBAction func familiarityTouchUpInside(sender: UISlider) {
        sender.setValue(familiaritySliderRoundValue(sender.value), animated: true)
        station?.undergroundness = familiaritySliderValueMap(sender.value)
        somethingChanged = true
    }
    
    
    @IBAction func familiarityTouchUpOutside(sender: UISlider) {
        print("familiarityTouchUpOutside")
    }
    
    func familiaritySliderRoundValue(value:Float) -> Float {
        return Float(round(value*4.0))/4.0
    }

    func familiaritySliderValueMap(value:Float) -> Int {
        return Int(value * 4) + 1
    }

    func familiaritySliderValueMapInverse(value:Int) -> Float {
        return Float(value - 1) / 4.0
    }
    
    @IBAction func doneAction(sender: AnyObject) {
        if self.station != nil {
            let energyPage = self.energyChartViewPageScrollController!.currentPageIndex
            let params = [
                "undergroundness": station!.undergroundness!,
                "name": profiles[energyPage]
            ] as [String: AnyObject]
            ModelManager.sharedInstance.generateTracksForStationWithParameters(station: self.station!, params: params) {
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationViewController = segue.destinationViewController as? PlaylistViewController {
            destinationViewController.station = station
        }
        if let vc = segue.destinationViewController as? PageScrollViewController {
            energyChartViewPageScrollController = vc
            energyChartViewPageScrollController!.station = station
            energyChartViewPageScrollController?.pageScrollDelegate = self
        }
        if let vc = segue.destinationViewController as? WeatherSideScrollerViewController {
            weatherSideScrollerViewController = vc
        }
        if let vc = segue.destinationViewController as? RecommendedSideScrollerViewController {
            recommendedSideScrollerViewController = vc
        }
    }

    func familiarityTapRecognized(tap:UITapGestureRecognizer) {
        if tap.state == .Ended {
            if let view = tap.view {
                let point = tap.locationInView(view)
                familiaritySlider.setValue(familiaritySliderRoundValue(Float(point.x/view.frame.size.width)), animated: true)
                station?.undergroundness = familiaritySliderValueMap(familiaritySlider.value)
                somethingChanged = true
            }
        }
    }
    
    func setupFamiliaritySlider() {
        familiaritySlider.setThumbImage(UIImage(named: "slider"), forState: .Normal)
        familiaritySlider.setMaximumTrackImage(UIImage(named: "empty-point"), forState: .Normal)
//        familiaritySlider.setMaximumTrackImage(UIImage(named: "slider-bg"), forState: .Normal)
        familiaritySlider.tintColor = UIColor.clearColor()
        familiaritySlider.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(EditStationViewController.familiarityTapRecognized(_:))))
    }

}
