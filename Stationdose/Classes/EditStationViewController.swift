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
    
    var station: Station?
    
    @IBOutlet weak internal var coverImageView: UIImageView!
    @IBOutlet weak internal var nameLabel: UILabel!
    @IBOutlet weak var updatedAtLabel: UILabel!
    @IBOutlet weak var familiarityOutlet: UIView!
    @IBOutlet weak var shortDescriptionLabel: UILabel!
    @IBOutlet weak var familiaritySlider: UISlider!
    
    private let fullscreenView = FullScreenLoadingView()
    private var somethingChanged: Bool = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(EditStationViewController.stationDidChangeUpdatedAt(_:)), name: SongSortApiManagerNotificationKey.StationDidChangeUpdatedAt.rawValue, object: nil)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0)))
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
            
            if station.undergroundness == nil {
                station.undergroundness = 3
            }
            
            familiaritySlider.value = familiaritySliderValueMapInverse(station.undergroundness!)
        }
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
    
    @IBAction func familiarityInfoAction(sender: AnyObject) {
        AlertView(title: "Familiarity", message: "Pretty much what it says on the tin. Stationdose won’t go too crazy with the sounds from the middle of the slide-bar, left. Slide right and hear the best B-sides, rare releases and out-there tracks in the genre. We suggest you get adventurous!", acceptButtonTitle: "Cool", cancelButtonTitle: nil) { (_) -> Void in }.show()
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
//        self.dismissViewControllerAnimated(true) { () -> Void in }
        if !somethingChanged {
            self.navigationController?.popViewControllerAnimated(true)
            return
        }
        
        AlertView(title: "Update Playlist Now?", message: "You’ve made changes to your station, do you want to update the playlist now?", acceptButtonTitle: "Update Now", cancelButtonTitle: "Update Later") {
            (accept) -> Void in
            
            if accept {
                if self.station != nil {
                    ModelManager.sharedInstance.updateStationAndRegenerateTracksIfNeeded(self.station!, regenerateTracks: true) {
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                } else {
                    if self.station != nil{
                        ModelManager.sharedInstance.updateStationAndRegenerateTracksIfNeeded(self.station!, regenerateTracks: false) {
                            self.navigationController?.popViewControllerAnimated(true)
                        }
                    } else {
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                }
            }
        }.show()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationViewController = segue.destinationViewController as? PlaylistViewController {
            destinationViewController.station = station
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
        familiaritySlider.tintColor = UIColor.clearColor()
        familiaritySlider.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(EditStationViewController.familiarityTapRecognized(_:))))
    }

}
