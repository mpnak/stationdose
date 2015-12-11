//
//  Constants.swift
//  Stationdose
//
//  Created by Developer on 11/15/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import Foundation

struct Constants {
    struct Spotify {
        static let ClientId = "dcc5c23ee5e94b6c9583667061a37913"
        static let ClientSecret = "5affe6aadabb400aafe1115ebe59528a"
        static let RedirectUrl = "stationdose-login://callback"
        static let RefreshUrl = "https://polar-dawn-6054.herokuapp.com/api/spotify/refresh"
        static let SwapUrl = "https://polar-dawn-6054.herokuapp.com/api/spotify/swap"
        static let GoPremiumUrl = NSURL(string:"https://www.spotify.com/premium")
    }
    struct Notifications{
        static let sessionValidNotification = "com.stationdose.sessionValidNotificationKey"
        static let sessionErrorNotification = "com.stationdose.sessionErrorNotificationKey"
        static let playbackCurrentTrackDidChange = "com.stationdose.playbackCurrentTrackDidChange"
    }
    struct Segues {
        static let LoginToHomeSegue = "LoginToHomeSegue"
        static let SplashToLoginSegue = "SplashToLoginSegue"
        static let SplashToHomeSegue = "SplashToHomeSegue"
        static let LoginToRequestPremiumSegue = "LoginToRequestPremiumSegue"
        static let SplashToRequestPremiumSegue = "SplashToRequestPremiumSegue"
        static let RequestPremiumToHomeSegue = "RequestPremiumToHomeSegue"
        static let RequestPremiumToRequestPremiumWebSegue = "RequestPremiumToRequestPremiumWebSegue"
    }
    
    struct SognSort{
        static let baseDevelopmentUrl = "https://polar-dawn-6054.herokuapp.com/api/"
    }
}
