 //
//  SpotifyManager.swift
//  Stationdose
//
//  Created by Developer on 11/16/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit

class SpotifyManager: NSObject {
    
    static let sharedInstance = SpotifyManager()
    
    var hasSession:Bool{
        return SPTAuth.defaultInstance().session != nil
    }
    
    var hasValidSession:Bool{
        return SPTAuth.defaultInstance().session.isValid()
    }
    
    var session:SPTSession!{
        return SPTAuth.defaultInstance().session;
    }
    
    var audioStreamingController:SPTAudioStreamingController?
    
    private let callback:SPTAuthCallback = {(error: NSError!,session: SPTSession!) in
        
        if let error = error {
            let errorNotification = NSNotification(name: Constants.Notifications.sessionErrorNotification,
                object: error)
            NSNotificationCenter.defaultCenter().postNotification(errorNotification)
            SpotifyManager.sharedInstance.audioStreamingController = nil
        } else {
            let validSessionNotification = NSNotification(name: Constants.Notifications.sessionValidNotification,
                object: session)
            NSNotificationCenter.defaultCenter().postNotification(validSessionNotification)
            SpotifyManager.sharedInstance.audioStreamingController = SPTAudioStreamingController(clientId: SPTAuth.defaultInstance().clientID)
        }
    }
    
    override init() {
        let spotifyAuthenticator = SPTAuth.defaultInstance()
        spotifyAuthenticator.clientID = Constants.Spotify.ClientId
        spotifyAuthenticator.redirectURL = NSURL(string: Constants.Spotify.RedirectUrl)
        spotifyAuthenticator.sessionUserDefaultsKey = "SpotifySession"
        spotifyAuthenticator.requestedScopes = [SPTAuthStreamingScope,SPTAuthUserReadPrivateScope]
        spotifyAuthenticator.tokenRefreshURL = NSURL(string:Constants.Spotify.RefreshUrl)
        spotifyAuthenticator.tokenSwapURL = NSURL(string:Constants.Spotify.SwapUrl)
    }
    
    func handleOpenURL(url: NSURL) ->Bool {
        if(SPTAuth.defaultInstance().canHandleURL(url)){
            SPTAuth.defaultInstance().handleAuthCallbackWithTriggeredAuthURL(url, callback: callback)
            return true

        }
        return false
    }
    
    func openLogin() {
        let spotifyAuthenticator = SPTAuth.defaultInstance()
        UIApplication.sharedApplication().openURL(spotifyAuthenticator.loginURL)
        //UIApplication.sharedApplication().openURL(Constants.Spotify.LoginUrl!)
    }
    
    func checkPremium(callback:(Bool)->()) {
        SPTUser.requestCurrentUserWithAccessToken(session.accessToken) { (error, user) in
            callback(user?.product == .Premium)
        }
    }
    
    func renewSession() {
        SPTAuth.defaultInstance().renewSession(session, callback: callback)
        
    }
}
