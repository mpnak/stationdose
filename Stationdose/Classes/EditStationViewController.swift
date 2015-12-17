//
//  EditStationViewController.swift
//  Stationdose
//
//  Created by Washington Miranda on 12/16/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit

class EditStationViewController: BaseViewController {
    
    internal var savedStation: SavedStation?
    
    @IBOutlet weak internal var coverImageView: UIImageView!
    @IBOutlet weak internal var nameLabel: UILabel!
    @IBOutlet weak var updatedAtLabel: UILabel!
    
    @IBOutlet weak var weatherSwitch: UISwitch!
    @IBOutlet weak var timeSwitch: UISwitch!
    @IBOutlet weak var familiaritySlider: UISlider!
    @IBOutlet weak var autoUpdateSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0)))
            
        nameLabel?.text = savedStation?.station?.name
        
        if let imageUrl = savedStation?.station?.art {
            let url = NSURL(string: imageUrl)!
            coverImageView?.af_setImageWithURL(url)
        }
        
        setupFamiliaritySlider()
        
        familiaritySlider.value = Float((savedStation?.undergroundness)!)/4.0
        weatherSwitch.on = (savedStation?.useWeather)!
        timeSwitch.on = (savedStation?.useTimeofday)!
        autoUpdateSwitch.on = (savedStation?.autoupdate)!
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
    }
    
    @IBAction func timeSwitchValueChange(sender: UISwitch) {
        savedStation?.useTimeofday = sender.on
    }
    
    @IBAction func autoUpdateSwitchValueChange(sender: UISwitch) {
        savedStation?.autoupdate = sender.on
    }
    
    @IBAction func familiarityTouchUpInside(sender: UISlider) {
        sender.setValue(familiaritySliderRoundValue(sender.value), animated: true)
        savedStation?.undergroundness = Int(sender.value * 4);
    }
    
    @IBAction func familiarityTouchUpOutside(sender: UISlider) {
        print("familiarityTouchUpOutside")
    }
    
    func familiaritySliderRoundValue(value:Float) -> Float {
        return Float(round(value*4.0))/4.0
    }
    
    @IBAction func doneAction(sender: AnyObject) {
//        self.dismissViewControllerAnimated(true) { () -> Void in }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func familiarityTapRecognized(tap:UITapGestureRecognizer) {
        if tap.state == .Ended {
            if let view = tap.view {
                let point = tap.locationInView(view)
                familiaritySlider.setValue(familiaritySliderRoundValue(Float(point.x/view.frame.size.width)), animated: true)
                savedStation?.undergroundness = Int(familiaritySlider.value * 4);
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
