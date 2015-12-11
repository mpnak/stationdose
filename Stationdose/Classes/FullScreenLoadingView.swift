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
    
    required override init () {
        internalView = InternalFullScreenLoadingView.instanceFromNib()
        blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
        hidden = false
        super.init()
    }
    
    func show(delay:Double) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            if !self.hidden {
                self.show()
            }
        }
    }
    
    func show() {
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
    
    func hide() {
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
