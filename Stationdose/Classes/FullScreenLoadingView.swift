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
    
    required override init () {
        internalView = InternalFullScreenLoadingView.instanceFromNib()
        blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
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
    
    private func setupBlur() {
        
        internalView.layoutIfNeeded()
        
        blurEffectView.frame = internalView.bounds
        internalView.superview!.insertSubview(blurEffectView, belowSubview: internalView)
        self.blurEffectView.alpha = 0.7
        
        
        internalView.layoutIfNeeded()
        
    }
    
    func hide() {
        UIApplication.sharedApplication().keyWindow!.windowLevel = UIWindowLevelNormal
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.internalView.alpha = 0
            }) { (_) -> Void in
                self.internalView.removeFromSuperview()
                self.blurEffectView.removeFromSuperview()
        }
    }


}
