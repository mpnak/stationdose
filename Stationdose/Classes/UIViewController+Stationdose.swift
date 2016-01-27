//
//  UIViewController+Stationdose.swift
//  Stationdose
//
//  Created by Developer on 11/16/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func addFullBackground() {
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "full_background")!)
    }
    
    func showGenericErrorMessage(){
        AlertView.genericErrorAlert().show()
    }
    
    func showCustomBack() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "btn-back"), style: .Plain, target: self, action: "back")
    }
    
    func back () {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func showUserProfileButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "profile-icon"), style: .Plain, target: self, action: "oppenUserProfileAction")
    }
    
    func showBrandingTitleView() {
        navigationItem.titleView = UIImageView(image: UIImage(named: "logo-min"))
    }
    
    func oppenUserProfileAction() {
        
        let alert = UIAlertController(title: "", message: "Are you sure you want to sign out?", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (_) -> Void in }))
        alert.addAction(UIAlertAction(title: "Sign Out", style: .Default, handler: { (_) -> Void in
            SpotifyManager.sharedInstance.logout()
            PlaybackManager.sharedInstance.hide()
            self.navigationController?.dismissViewControllerAnimated(true, completion: { () -> Void in })
        }))
        self.presentViewController(alert, animated: true) { () -> Void in }
    }
    
    func showAlertFirstTimeAndSaveStation(savedStation:SavedStation){
        if (!NSUserDefaults.standardUserDefaults().boolForKey("firstlaunch1.0")) {
            AlertView(title: "Change influencers", message: "Changes will affect your playlist when you tap the refresh icon or the next time you open the app.", acceptButtonTitle: "That's cool", cancelButtonTitle: "Nevermind") {
                (_) -> Void in
                ModelManager.sharedInstance.updateSavedStationAndRegenerateTracksIfNeeded(savedStation, regenerateTracks: false) { }
            }.show()
            
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "firstlaunch1.0")
            NSUserDefaults.standardUserDefaults().synchronize();
        } else {
            ModelManager.sharedInstance.updateSavedStationAndRegenerateTracksIfNeeded(savedStation, regenerateTracks: false) { }
        }
    }
}
