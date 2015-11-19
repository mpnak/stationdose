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
        /*
        static let LoginUrl =  NSURL(string:"https://accounts.spotify.com/en/login?continue=https:%2F%2Faccounts.spotify.com%2Fen%2Fauthorize%3Fclient_id%3D"+ClientId+"%26scope%3Dstreaming%20user-read-private%26redirect_uri%3Dstationdose-app-login:%252F%252F%26nosignup%3Dfalse%26nolinks%3Dfalse%26response_type%3Dtoken")
        */
        static let GoPremiumUrl = NSURL(string:"https://www.spotify.com/premium")
    }
    struct Notifications{
        static let sessionValidNotification = "com.stationdose.sessionValidNotificationKey"
        static let sessionErrorNotification = "com.stationdose.sessionErrorNotificationKey"
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
}
