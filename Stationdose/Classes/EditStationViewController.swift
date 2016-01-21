//
//  EditStationViewController.swift
//  Stationdose
//
//  Created by Washington Miranda on 12/16/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit
import Foundation

class EditStationViewController: BaseViewController {
    
    internal var savedStation: SavedStation?
    
    @IBOutlet weak internal var coverImageView: UIImageView!
    @IBOutlet weak internal var nameLabel: UILabel!
    @IBOutlet weak var updatedAtLabel: UILabel!
    
    @IBOutlet weak var shortDescriptionLabel: UILabel!
    @IBOutlet weak var weatherSwitch: UISwitch!
    @IBOutlet weak var timeSwitch: UISwitch!
    @IBOutlet weak var familiaritySlider: UISlider!
    @IBOutlet weak var autoUpdateSwitch: UISwitch!
    
    private let fullscreenView = FullScreenLoadingView()
    private var somethingChanged:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"savedStationDidChangeUpdatedAt:", name: SongSortApiManagerNotificationKey.SavedStationDidChangeUpdatedAt.rawValue, object: nil)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0)))
            
        nameLabel?.text = savedStation?.station?.name
        shortDescriptionLabel?.text = savedStation?.station?.shortDescription
        updatedAtLabel?.text = savedStation?.updatedAtString()
        
        if let imageUrl = savedStation?.station?.art {
            let url = NSURL(string: imageUrl)!
            coverImageView?.af_setImageWithURL(url, placeholderImage: UIImage(named: "station-placeholder"))
        } else {
            coverImageView.image = UIImage(named: "station-placeholder")
        }
        
        setupFamiliaritySlider()
        
        if let savedStation = savedStation {
            
            if savedStation.undergroundness == nil {
                savedStation.undergroundness = 2
            }
            if savedStation.useWeather == nil {
                savedStation.useWeather = false
            }
            if savedStation.useTimeofday == nil {
                savedStation.useTimeofday = false
            }
            if savedStation.autoupdate == nil {
                savedStation.autoupdate = false
            }
            
            familiaritySlider.value = Float((savedStation.undergroundness)!)/4.0
            weatherSwitch.on = (savedStation.useWeather)!
            timeSwitch.on = (savedStation.useTimeofday)!
            autoUpdateSwitch.on = (savedStation.autoupdate)!
            
        } else {
            print("Error: savedStation missing")
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func savedStationDidChangeUpdatedAt(notification:NSNotification) {
        if let savedStation = notification.object as? SavedStation {
            if savedStation.id == self.savedStation?.id {
                updatedAtLabel?.text = savedStation.updatedAtString()
            }
        }
    }
    
    @IBAction func weatherInfoAction(sender: AnyObject) {
        AlertView(title: "Local weather", message: "Stationdose looks at your local weather conditions and adjusts your station accordingly. Rainy? Probably be a bit more mellow. Sunny? Expect your station to have a bit more bounce in its step.", acceptButtonTitle: "Cool", cancelButtonTitle: nil) { (_) -> Void in }.show()
    }
    
    @IBAction func timeInfoAction(sender: AnyObject) {
        AlertView(title: "Time of day", message: "Similar to using the weather to push your playlist a certain way, adding time of day will only amplify the effect. Rainy Monday morning? Gonna be a properly mellow playlist. Rainy Friday afternoon? Well we take one part rainy, add two parts Friday, a half-tablespoon of afternoon, and whip up a rocktail that won’t dissapoint. Served with a twist of lime.", acceptButtonTitle: "Cool", cancelButtonTitle: nil) { (_) -> Void in }.show()
    }
    
    @IBAction func familiarityInfoAction(sender: AnyObject) {
        AlertView(title: "Familiarity", message: "Pretty much what it says on the tin. Stationdose won’t go too crazy with the sounds from the middle of the slide-bar, left. Slide right and hear the best B-sides, rare releases and out-there tracks in the genre. We suggest you get adventurous!", acceptButtonTitle: "Cool", cancelButtonTitle: nil) { (_) -> Void in }.show()
    }
    
    @IBAction func weatherSwitchValueChange(sender: UISwitch) {
        savedStation?.useWeather = sender.on
        somethingChanged = true
    }
    
    @IBAction func timeSwitchValueChange(sender: UISwitch) {
        savedStation?.useTimeofday = sender.on
        somethingChanged = true
    }
    
    @IBAction func autoUpdateSwitchValueChange(sender: UISwitch) {
        savedStation?.autoupdate = sender.on
    }
    
    @IBAction func familiarityTouchUpInside(sender: UISlider) {
        sender.setValue(familiaritySliderRoundValue(sender.value), animated: true)
        savedStation?.undergroundness = Int(sender.value * 4);
        somethingChanged = true
    }
    
    
    @IBAction func familiarityTouchUpOutside(sender: UISlider) {
        print("familiarityTouchUpOutside")
    }
    
    func familiaritySliderRoundValue(value:Float) -> Float {
        return Float(round(value*4.0))/4.0
    }
    
    @IBAction func doneAction(sender: AnyObject) {
//        self.dismissViewControllerAnimated(true) { () -> Void in }
        if !somethingChanged {
            self.navigationController?.popViewControllerAnimated(true)
            return
        }
        
        AlertView(title: "Update Playlist Now?", message: "You’ve made changes to your station, do you want to update the playlist now?", acceptButtonTitle: "Update Now", cancelButtonTitle: "Update Later") {
            (accept) -> Void in
            
            if accept {
                ModelManager.sharedInstance.updateSavedStationAndRegenerateTracksIfNeeded(self.savedStation!, regenerateTracks: true) {
                    self.navigationController?.popViewControllerAnimated(true)
                }
            } else {
                ModelManager.sharedInstance.updateSavedStationAndRegenerateTracksIfNeeded(self.savedStation!, regenerateTracks: false) {
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
        }.show()

    }
    
    func familiarityTapRecognized(tap:UITapGestureRecognizer) {
        if tap.state == .Ended {
            if let view = tap.view {
                let point = tap.locationInView(view)
                familiaritySlider.setValue(familiaritySliderRoundValue(Float(point.x/view.frame.size.width)), animated: true)
                savedStation?.undergroundness = Int(familiaritySlider.value * 4);
                somethingChanged = true
            }
        }
    }
    
    func setupFamiliaritySlider() {
        familiaritySlider.setThumbImage(UIImage(named: "slider"), forState: .Normal)
        familiaritySlider.setMaximumTrackImage(UIImage(named: "empty-point"), forState: .Normal)
        familiaritySlider.tintColor = UIColor.clearColor()
        familiaritySlider.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "familiarityTapRecognized:"))
    }

}
