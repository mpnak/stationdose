//
//  Station.swift
//  Stationdose
//
//  Created by Developer on 11/25/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import Foundation
import ObjectMapper

class Station: Mappable {
    
    var id:Int?
    var name:String?
    var shortDescription:String?
    var type:String?
    var art:String?
    var url:String?
    var tracks:[Track]?
    var isPlaying:Bool?
    
    required init?(_ map: Map) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setIsPlayingFalse", name: "noOneIsPlayingNotifiactionKey", object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func mapping(map: Map) {
        id                  <- map["id"]
        name                <- map["name"]
        shortDescription    <- map["short_description"]
        type                <- map["station_type"]
        art                 <- map["station_art"]
        url                 <- map["url"]
    }
    
    static func noOneIsPlaying() {
        NSNotificationCenter.defaultCenter().postNotificationName("noOneIsPlayingNotifiactionKey", object: nil)
    }
    
    private func setIsPlayingFalse() {
        isPlaying = false
    }

}
