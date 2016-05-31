//
//  PlaylistProfileChooser.swift
//  Stationdose
//
//  Created by Hoof on 5/10/16.
//  Copyright © 2016 Stationdose. All rights reserved.
//

import UIKit
import ObjectMapper

class PlaylistProfileChooser: Mappable {
    
    var name: String?
    var weather: String?
    var localtime: String?
    var allnames: [String]?
    var timezone: String?
    
    //{"name":"club","weather":"partly-cloudy-day","localtime":"2016-05-10T18:05:30-07:00","day":2,"all_names":["mellow","chill","vibes","lounge","club","bangin"],"timezone":"America/Los_Angeles"}
    
    required init?(_ map: Map) {
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Station.setIsPlayingFalse), name: "noOneIsPlayingNotifiactionKey", object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func mapping(map: Map) {
        name                <- map["name"]
        weather             <- map["weather"]
        localtime           <- map["localtime"]
        allnames            <- map["allnames"]
        timezone            <- map["timezone"]
    }
}
