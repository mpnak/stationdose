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
        static let ClientId = "0b23eb44f6d345c998dbb61766a35e8d"
        static let ClientSecret = "91980d6e26fe451496a1ffc5b7305662"
        static let RedirectUrl = "stationdose-app-login://"
        static let LoginUrl =  NSURL(string:"https://accounts.spotify.com/en/login?continue=https:%2F%2Faccounts.spotify.com%2Fen%2Fauthorize%3Fclient_id%3D"+ClientId+"%26scope%3Dstreaming%20user-read-private%26redirect_uri%3Dstationdose-app-login:%252F%252F%26nosignup%3Dfalse%26nolinks%3Dfalse%26response_type%3Dtoken")
        static let GoPremiumUrl = NSURL(string:"https://www.spotify.com/premium")
    }
    struct Notifications{
        static let sessionValidNotification = "com.stationdose.sessionValidNotificationKey"
        static let sessionErrorNotification = "com.stationdose.sessionValidNotificationKey"
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
