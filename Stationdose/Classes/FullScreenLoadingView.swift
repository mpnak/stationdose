//
//  FullScreenLoadingView.swift
//  Stationdose
//
//  Created by Developer on 12/10/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit

class FullScreenLoadingView: NSObject {
    
    private var internalView :InternalFullScreenLoadingView
    private var blurEffectView :UIVisualEffectView
    private var hidden:Bool
    private var showDate:NSDate?
    
    required override init () {
        internalView = InternalFullScreenLoadingView.instanceFromNib()
        blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
        hidden = false
        super.init()
    }
    
    func show(delay:Double) {
        self.hidden = false
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            if !self.hidden {
                self.internalShow()
            }
        }
    }
    
    func show() {
        self.hidden = false
        internalShow()
    }
    
    private func internalShow() {
        showDate = NSDate()
        
        let window = UIApplication.sharedApplication().keyWindow!
        
        window.windowLevel = UIWindowLevelStatusBar + 1
        
        internalView.frame = window.bounds
        internalView.alpha = 0
        window.addSubview(internalView)

        self.setupBlur()
        
        UIView.animateWithDuration(0.2) { () -> Void in
            self.internalView.alpha = 1
        }
    }
    
    func setMessage(message:String){
        internalView.messageLabel.text = message
    }
    
    private func setupBlur() {
        
        internalView.layoutIfNeeded()
        
        blurEffectView.frame = internalView.bounds
        internalView.superview!.insertSubview(blurEffectView, belowSubview: internalView)
        self.blurEffectView.alpha = 0.7
        
        
        internalView.layoutIfNeeded()
        
    }
    
    func hide(minTime:Double) {
        var elapsedTime = 0.0
        if let showDate = showDate {
            elapsedTime = Double(NSDate().timeIntervalSinceDate(showDate))
        }
        
        if elapsedTime>0 && minTime-elapsedTime > 0 {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(minTime-elapsedTime * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                self.hide(minTime)
            }
        } else {
            hidden = true
            UIApplication.sharedApplication().keyWindow!.windowLevel = UIWindowLevelNormal
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.internalView.alpha = 0
                }) { (_) -> Void in
                    self.internalView.removeFromSuperview()
                    self.blurEffectView.removeFromSuperview()
            }
        }
    }
    
    func hide() {
        hide(0)
    }

}
