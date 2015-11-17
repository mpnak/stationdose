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
    }
    struct Notifications{
        static let sessionValidNotification = "com.stationdose.sessionValidNotificationKey"
        static let sessionErrorNotification = "com.stationdose.sessionValidNotificationKey"
    }
    struct Segues {
        static let LoginToHomeSegue = "LoginToHomeSegue"
        static let SplashToLoginSegue = "SplashToLoginSegue"
        static let SplashToHomeSegue = "SplashToHomeSegue"
    }
}
