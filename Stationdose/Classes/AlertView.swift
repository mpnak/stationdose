//
//  AlertView.swift
//  Stationdose
//
//  Created by Developer on 11/26/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit

class AlertView: NSObject {
    
    var title :String
    var message :String
    var acceptButtonTitle :String
    var cancelButtonTitle :String?
    var callback : (accept: Bool) -> Void
    
    private var contaignerView :InternalAlertView
    private var blurEffectView :UIVisualEffectView
//    private var alertWindow :UIWindow?
    
    static var retainedSelfs :[AlertView] = []
    
    required init (title: String, message: String, acceptButtonTitle: String, cancelButtonTitle: String?, callback: (accept: Bool) -> Void ) {
        
        contaignerView = InternalAlertView.instanceFromNib()
        blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
        
        self.title = title
        self.message = message
        self.acceptButtonTitle = acceptButtonTitle
        self.cancelButtonTitle = cancelButtonTitle
        self.callback = callback
        
        super.init()
    }
    
    class func genericErrorAlert()->AlertView {
        return AlertView(title: "Error", message: "Sorry, we seem to be having technical difficulties.", acceptButtonTitle: "Go Back", cancelButtonTitle: nil, callback: { (_) -> Void in })
    }
    
    func show() {
        
        if AlertView.retainedSelfs.indexOf(self) != nil {
            return
        }
        
        AlertView.retainedSelfs.append(self)
        
        let window = UIApplication.sharedApplication().keyWindow!
        
//        alertWindow = UIWindow(frame: window.frame)
//        alertWindow?.backgroundColor = UIColor.redColor()
//        alertWindow?.windowLevel = UIWindowLevelAlert
//        alertWindow?.makeKeyWindow()
//        alertWindow?.hidden = false
        
//        contaignerView.frame = (alertWindow?.bounds)!
//        contaignerView.alpha = 0
//        alertWindow?.addSubview(contaignerView)
//        self.setupContaignerViews()
        
        window.windowLevel = UIWindowLevelStatusBar + 1
        
        contaignerView.frame = window.bounds
        contaignerView.alpha = 0
        window.addSubview(contaignerView)
        self.setupContaignerViews()
        
        UIView.animateWithDuration(0.2) { () -> Void in
            self.contaignerView.alpha = 1
            self.blurEffectView.alpha = 1
        }
    }
    
    func acceptAction() {
        callback(accept: true)
        hide()
    }
    
    func cancelAction() {
        callback(accept: false)
        hide()
    }
    
    private func setupContaignerViews() {
        
        contaignerView.layoutIfNeeded()
        
        blurEffectView.frame = contaignerView.bounds
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        contaignerView.superview!.insertSubview(blurEffectView, belowSubview: contaignerView)
        
        contaignerView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.0)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("cancelAction"))
        contaignerView.addGestureRecognizer(tapGestureRecognizer)
        
        contaignerView.titleLabel.text = title
        contaignerView.messageLabel.text = message
        contaignerView.acceptButton.setTitle(acceptButtonTitle, forState: .Normal)
        contaignerView.acceptButton.addTarget(self, action: "acceptAction", forControlEvents: .TouchUpInside)
        contaignerView.closeButton.addTarget(self, action: "cancelAction", forControlEvents: .TouchUpInside)
        
        if let cancelButtonTitle = cancelButtonTitle {
            contaignerView.cancelButton.setTitle(cancelButtonTitle, forState: .Normal)
            contaignerView.cancelButtonWidthLayoutConstraint.constant = (contaignerView.cancelButton.superview?.frame.size.width)!/2.0
            contaignerView.cancelButton.addTarget(self, action: "cancelAction", forControlEvents: .TouchUpInside)
        } else {
            contaignerView.cancelButtonWidthLayoutConstraint.constant = 0.0
        }
        
        contaignerView.layoutIfNeeded()
        
    }
    
    private func hide() {
        UIApplication.sharedApplication().keyWindow!.windowLevel = UIWindowLevelNormal
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.contaignerView.alpha = 0
            self.blurEffectView.alpha = 0
        }) { (_) -> Void in
            self.contaignerView.removeFromSuperview()
            self.blurEffectView.removeFromSuperview()
            AlertView.retainedSelfs.removeAtIndex(AlertView.retainedSelfs.indexOf(self)!)
        }
    }
}
