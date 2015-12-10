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
    
    override init() {
        let spotifyAuthenticator = SPTAuth.defaultInstance()
        
        super.init()
        
        spotifyAuthenticator.clientID = Constants.Spotify.ClientId
        spotifyAuthenticator.redirectURL = NSURL(string: Constants.Spotify.RedirectUrl)
        spotifyAuthenticator.sessionUserDefaultsKey = "SpotifySession"
        spotifyAuthenticator.requestedScopes = [SPTAuthStreamingScope,SPTAuthUserReadPrivateScope]
        spotifyAuthenticator.tokenRefreshURL = NSURL(string:Constants.Spotify.RefreshUrl)
        spotifyAuthenticator.tokenSwapURL = NSURL(string:Constants.Spotify.SwapUrl)
        
        if spotifyAuthenticator.session.isValid() {
            self.player = SPTAudioStreamingController(clientId: spotifyAuthenticator.clientID)
        }
    }
    
    var hasSession:Bool{
        return SPTAuth.defaultInstance().session != nil
    }
    
    var hasValidSession:Bool{
        return SPTAuth.defaultInstance().session.isValid()
    }
    
    var session:SPTSession!{
        return SPTAuth.defaultInstance().session;
    }
    
    var player:SPTAudioStreamingController?
    
    private let callback:SPTAuthCallback = {(error: NSError!,session: SPTSession!) in
        
        if let error = error {
            let errorNotification = NSNotification(name: Constants.Notifications.sessionErrorNotification,
                object: error)
            NSNotificationCenter.defaultCenter().postNotification(errorNotification)
            
            SpotifyManager.sharedInstance.player = nil
            
        }else{

            SongSortApiManager.sharedInstance.renewSession(session.accessToken, onCompletion: { (user, error) -> Void in
                if let user = user where error == nil{
                    
                    ModelManager.sharedInstance.reloadCache({ () -> Void in
                    })
                    
                    ModelManager.sharedInstance.user = user
                    let validSessionNotification = NSNotification(name: Constants.Notifications.sessionValidNotification,
                        object: session)
                    NSNotificationCenter.defaultCenter().postNotification(validSessionNotification)
                }else{
                    let errorNotification = NSNotification(name: Constants.Notifications.sessionErrorNotification,
                        object: error)
                    NSNotificationCenter.defaultCenter().postNotification(errorNotification)
                }
            })
            
            SpotifyManager.sharedInstance.player = SPTAudioStreamingController(clientId: SPTAuth.defaultInstance().clientID)
        }
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
