 //
//  SpotifyManager.swift
//  Stationdose
//
//  Created by Developer on 11/16/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit
import SafariServices

protocol SpotifyManagerLoginDelegate {
    func loginAcountNeedsPremium() -> Void
    func loginSuccess() -> Void
    func loginFailure(error: NSError?) -> Void
    func loginCancelled() -> Void
}

class SpotifyManager: NSObject, SFSafariViewControllerDelegate {
    static let sharedInstance = SpotifyManager()
    
    override init() {
        let spotifyAuthenticator = SPTAuth.defaultInstance()
        
        super.init()
        
        spotifyAuthenticator.clientID = Constants.Spotify.ClientId
        spotifyAuthenticator.redirectURL = NSURL(string: Constants.Spotify.RedirectUrl)
        spotifyAuthenticator.sessionUserDefaultsKey = "SpotifySession"
        spotifyAuthenticator.requestedScopes = [SPTAuthStreamingScope, SPTAuthUserReadPrivateScope, SPTAuthPlaylistModifyPrivateScope]
        spotifyAuthenticator.tokenRefreshURL = NSURL(string:Constants.Spotify.RefreshUrl)
        spotifyAuthenticator.tokenSwapURL = NSURL(string:Constants.Spotify.SwapUrl)
    }
    
    var hasSession: Bool {
        return SPTAuth.defaultInstance().session != nil
    }
    
    var hasValidSession: Bool {
        return SPTAuth.defaultInstance().session.isValid()
    }
    
    var session: SPTSession! {
        return SPTAuth.defaultInstance().session
    }
    
    var clientID: String {
        return SPTAuth.defaultInstance().clientID
    }
    
    //var player: SPTAudioStreamingController?
    
    var loginDelegate: SpotifyManagerLoginDelegate?
    
    // Store a reference to the view controller supplied in openLogin
    var sfLoginViewController: SFSafariViewController?

    /**
     Endpoint for login.
     
     A SFSafariViewController login screen is presented. If the user correctly submits the login form Spotify will initiate callback request that will land at the handleOpenURL(url: NSURL) ->Bool function.
     
     - Parameters:
     - viewController a UIViewController that presents the login screen.
     - callback to be called when dismissing the login screen.
     
     */
    
    func openLogin(viewController: UIViewController) {
        let spotifyAuthenticator = SPTAuth.defaultInstance()
        sfLoginViewController = SFSafariViewController(URL: spotifyAuthenticator.loginURL)
        sfLoginViewController?.delegate = self
        
        loginDelegate = viewController as? SpotifyManagerLoginDelegate
        
        viewController.presentViewController(sfLoginViewController!, animated: true, completion: nil)
    }
    
    /**
     Endpoint for login.
     
     Login using the existing session
     
     - Parameters:
     - loginDelegate
     
     */
    func loginWithExistingSession(loginDelegate: SpotifyManagerLoginDelegate) {
        self.loginDelegate = loginDelegate
        SPTAuth.defaultInstance().renewSession(session, callback: spotifyAuthCallback)
    }
    
    /**
     Endpoint for logout.
     
     */

    func logout() {
        return SPTAuth.defaultInstance().session = nil
    }
    
    func spotifyAuthCallback(error: NSError!, session: SPTSession!) -> Void {
        if let error = error {
            print(error)
            self.loginFailure(error)
        } else {
            self.checkPremium({ (isPremium: Bool) -> Void in
                if isPremium {
                    self.loginToSongSort(session)
                } else {
                    self.loginAcountNeedsPremium()
                }
            })
        }
    }
    
    func loginSuccess() {
        self.loginDelegate?.loginSuccess()
        self.loginDelegate = nil
    }
    
    func loginFailure(error: NSError?) {
        self.loginDelegate?.loginFailure(error!)
        self.loginDelegate = nil
    }
    
    func loginAcountNeedsPremium() {
        self.loginDelegate?.loginAcountNeedsPremium()
        self.loginDelegate = nil
    }
    
    func loginCancelled() {
        loginDelegate?.loginCancelled()
        self.loginDelegate = nil
    }
    
    func completeLogin(user: User) {
        PlaybackManager.sharedInstance.setupPlayer() // Bubbles away sync (probably not good)
        ModelManager.sharedInstance.user = user
        ModelManager.sharedInstance.initialCache { () -> Void in
            self.loginSuccess()
        }
    }
    
    func loginToSongSort(session: SPTSession) {
        SongSortApiManager.sharedInstance.renewSession(session.accessToken, onCompletion: { (user, error) -> Void in
            if let user = user where error == nil {
                self.completeLogin(user)
            } else {
                self.loginFailure(error)
                
            }
        })
    }
 
    func handleOpenURL(url: NSURL) -> Bool {
        if(SPTAuth.defaultInstance().canHandleURL(url)) {
            dismissSafariLoginView()
            SPTAuth.defaultInstance().handleAuthCallbackWithTriggeredAuthURL(url, callback: spotifyAuthCallback)
            return true
        }
        return false
    }
    
    func dismissSafariLoginView() {
        if let sfVC = sfLoginViewController {
            sfVC.dismissViewControllerAnimated(true, completion: nil)
            self.sfLoginViewController = nil
        }
    }
    
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        loginCancelled()
        dismissSafariLoginView()
    }
    
    func checkPremium(callback: (Bool) -> Void) {
        SPTUser.requestCurrentUserWithAccessToken(session.accessToken) { (error, user) in
            callback(user?.product == .Premium)
        }
    }
   
    func createPlaylist(stationName: String, tracks :[Track], callback: (success: Bool) -> Void) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mma"
        dateFormatter.AMSymbol = "am"
        dateFormatter.PMSymbol = "pm"
        let playlistName = String(format:"Stationdose %@ - %@", stationName, dateFormatter.stringFromDate(NSDate()))
        SPTPlaylistList.createPlaylistWithName(playlistName, publicFlag: false, session: session) { (error, snapshot) -> Void in
            if let snapshot = snapshot {
                var tracksUrls = [NSURL]()
                for track in tracks {
                    if let url = NSURL(string:track.spotifyUrl()) {
                        tracksUrls.append(url)
                    }
                }
                SPTTrack.tracksWithURIs(tracksUrls, session: self.session, callback: { (error, tracks) -> Void in
                    if let tracks = tracks as? [SPTTrack] {
                        snapshot.addTracksToPlaylist(tracks, withSession: self.session, callback: { (error) -> Void in 
                            callback(success: error != nil)
                        })
                    } else {
                        callback(success: false)
                    }
                })
            } else {
                callback(success: false)
            }
        }
    }
}
