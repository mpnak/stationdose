//
//  AlertView.swift
//  Stationdose
//
//  Created by Developer on 12/21/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit
import Social
import MessageUI
import Branch

class ShareView: NSObject {
    
    enum ShareViewChannelType {
        case Facebook
        case Twitter
        case Email
    }
    
    var shareText: String
    var shareAppUrl: String
    var shareImage: UIImage?
    var shareImageUrl: NSURL?
    var shareUrl: NSURL?
    var tracks: [Track]?
    var presenterViewController: UIViewController
    var callback: (shared: Bool) -> Void
    
    private var contaignerView :InternalShareView
    private var blurEffectView :UIVisualEffectView
    
    static var retainedSelfs :[ShareView] = []
    
    required init (text: String, appUrl: String, presenterViewController: UIViewController, callback: (shared: Bool) -> Void ) {
        shareText = text
        shareAppUrl = appUrl
        self.callback = callback
        self.presenterViewController = presenterViewController
        
        contaignerView = InternalShareView.instanceFromNib()
        blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
        
        super.init()
    }
    
    
    class func genericErrorAlert()->AlertView{
        return AlertView(title: "Error", message: "Sorry, we seem to be having technical difficulties.", acceptButtonTitle: "Go Back", cancelButtonTitle: nil, callback: { (accept) -> Void in })
    }
    
    func show() {
        if ShareView.retainedSelfs.indexOf(self) != nil {
            return
        }
        
        ShareView.retainedSelfs.append(self)
        
        let window = UIApplication.sharedApplication().keyWindow!
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
    
    func getShortLink(channelTipe:ShareViewChannelType, callback: (url: NSURL?) -> Void) {
        let branchUniversalObject = BranchUniversalObject(canonicalIdentifier: shareAppUrl)
        
        let linkProperties: BranchLinkProperties = BranchLinkProperties()
        linkProperties.feature = "sharing"
        switch channelTipe {
        case .Facebook:
            linkProperties.channel = "facebook"
        case .Twitter:
            linkProperties.channel = "twitter"
        case .Email:
            linkProperties.channel = "email"
        }
        
        linkProperties.addControlParam("$deeplink_path", withValue: "test")
        linkProperties.addControlParam("$always_deeplink", withValue: "true")
        
        branchUniversalObject.getShortUrlWithLinkProperties(linkProperties, andCallback: { (url: String?, error: NSError?) -> Void in
            if let url = url {
                if let url = NSURL(string: url) {
                    callback(url: url)
                    return
                }
            }
            callback(url: nil)
        })
    }
    
    func shareBySocialNetwork(channelTipe:ShareViewChannelType) {
        guard channelTipe == ShareViewChannelType.Facebook || channelTipe == ShareViewChannelType.Twitter else { return }
        
        let sheet = SLComposeViewController(forServiceType: channelTipe == ShareViewChannelType.Facebook ? SLServiceTypeFacebook : SLServiceTypeTwitter)
        sheet.setInitialText(String(format: "I've been listening to %@ on Stationdose. Check it out! ", shareText))
        if let image = shareImage {
            sheet.addImage(image)
        }
        sheet.completionHandler = { (result) -> Void in
            self.callback(shared: result == .Done)
            self.hide()
        }
        
        getShortLink(channelTipe) { (url) -> Void in
            if let url = url {
                sheet.addURL(url)
            }
            self.presenterViewController.presentViewController(sheet, animated: true) { () -> Void in }
        }
    }
    
    func shareByFacebook() {
        shareBySocialNetwork(.Facebook)
    }
    
    func shareByTwitter() {
        shareBySocialNetwork(.Twitter)
    }
    
    func shareByEmail() {
        UINavigationBar.appearance().barTintColor = UIColor.whiteColor()
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        
        mailComposer.setSubject("Check it out!")
        
        getShortLink(.Email) { (url) -> Void in
            if let url = url {
                let message = String(format: "I've been listening to %@ on Stationdose. Check it out! <a href=\"%@\">%@</a>", self.shareText, url, url)
                mailComposer.setMessageBody(message, isHTML: true)
            } else {
                mailComposer.setMessageBody(String(format: "I've been listening to %@ on Stationdose. Check it out!", self.shareText), isHTML: false)
            }
            PlaybackManager.sharedInstance.alwaysOnTop = false
            self.presenterViewController.presentViewController(mailComposer, animated: true) { () -> Void in }
        }
    }
    
    func createPlaylist() {
        if let tracks = tracks {
            let fullscreenView = FullScreenLoadingView()
            fullscreenView.setMessage("Just a moment")
            fullscreenView.show()
            SpotifyManager.sharedInstance.createPlaylist(shareText, tracks: tracks, callback: { (success) -> Void in
                self.callback(shared: success)
                self.hide()
                fullscreenView.hide()
            })
        }
    }
    
    func cancelAction() {
        callback(shared: false)
        hide()
    }
    
    private func setupContaignerViews() {
        
        contaignerView.layoutIfNeeded()
        
        blurEffectView.frame = contaignerView.bounds
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        contaignerView.superview!.insertSubview(blurEffectView, belowSubview: contaignerView)
        
        contaignerView.facebookButton.addTarget(self, action: #selector(ShareView.shareByFacebook), forControlEvents: .TouchUpInside)
        contaignerView.twitterButton.addTarget(self, action: #selector(ShareView.shareByTwitter), forControlEvents: .TouchUpInside)
        contaignerView.emailButton.addTarget(self, action: #selector(ShareView.shareByEmail), forControlEvents: .TouchUpInside)
        if let presenter = self.presenterViewController as? FeaturedStationViewController{                            contaignerView.createPlaylistButton.hidden = presenter.station!.type == "featured" ? true : false
            contaignerView.emailBtnConstraint.constant = presenter.station!.type == "featured" ? CGFloat(20.0) : CGFloat(84.0)
        }

        contaignerView.createPlaylistButton.addTarget(self, action: #selector(ShareView.createPlaylist), forControlEvents: .TouchUpInside)
        

        contaignerView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.0)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ShareView.cancelAction))
        contaignerView.addGestureRecognizer(tapGestureRecognizer)
        
        contaignerView.closeButton.addTarget(self, action: #selector(ShareView.cancelAction), forControlEvents: .TouchUpInside)
        
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
            ShareView.retainedSelfs.removeAtIndex(ShareView.retainedSelfs.indexOf(self)!)
        }
    }
}

extension ShareView: MFMailComposeViewControllerDelegate {
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true) { () -> Void in
            self.callback(shared: result==MFMailComposeResultSaved)
            self.hide()
            PlaybackManager.sharedInstance.alwaysOnTop = true
        }
        UINavigationBar.appearance().barTintColor = UIColor.customAppBackgroundColor()
    }
}
