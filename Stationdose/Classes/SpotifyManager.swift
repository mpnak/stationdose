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
    
    
    private let callback:SPTAuthCallback = {(error: NSError!,session: SPTSession!) in
        
        if let error = error{
            let errorNotification = NSNotification(name: Constants.Notifications.sessionErrorNotification,
                object: error)
            NSNotificationCenter.defaultCenter().postNotification(errorNotification)
        }else{
            let validSessionNotification = NSNotification(name: Constants.Notifications.sessionValidNotification,
                object: error)
            NSNotificationCenter.defaultCenter().postNotification(validSessionNotification)
            
        }
    }
    
    
    
    
    override init() {
        let spotifyAuthenticator = SPTAuth.defaultInstance()
        spotifyAuthenticator.clientID = Constants.Spotify.ClientId
        spotifyAuthenticator.redirectURL = NSURL(string: Constants.Spotify.RedirectUrl)
        spotifyAuthenticator.sessionUserDefaultsKey = "SpotifySession"
        spotifyAuthenticator.requestedScopes = [SPTAuthStreamingScope]
    }
    
    func handleOpenURL(url: NSURL) ->Bool{
        if(SPTAuth.defaultInstance().canHandleURL(url)){
            SPTAuth.defaultInstance().handleAuthCallbackWithTriggeredAuthURL(url, callback: callback)
            return true
            
        }
        return false
    }
    
    func openLogin(){

        let spotifyAuthenticator = SPTAuth.defaultInstance()
        UIApplication.sharedApplication().openURL(spotifyAuthenticator.loginURL)
    }
    
    func renewSession(){
        SPTAuth.defaultInstance().renewSession(session, callback: callback)
        
    }

}
