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
    
    var id: Int?
    var name: String?
    var shortDescription: String?
    var type: String?
    var art: String?
    var url: String?
    var undergroundness: Int?
    var tracksUpdatedAt: NSDate?
    var savedStation: Bool?
    var tracks: [Track]?
    var isPlaying: Bool?
    var playlistProfile: String?
    var playlistProfileChooser: PlaylistProfileChooser?
    var isStandardType: Bool {
        get {
            return self.type == "standard"
        }
    }
    
    required init?(_ map: Map) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Station.setIsPlayingFalse), name: "noOneIsPlayingNotifiactionKey", object: nil)
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
        
        undergroundness     <- map["undergroundness"]
        savedStation        <- map["saved_station"]
        tracksUpdatedAt     <- (map["tracks_updated_at"], ISO8601DateTransform())
        tracks              <- map["tracks"]
    }
    
    static func noOneIsPlaying() {
        NSNotificationCenter.defaultCenter().postNotificationName("noOneIsPlayingNotifiactionKey", object: nil)
    }
    
    @objc private func setIsPlayingFalse() {
        isPlaying = false
    }
    
    func updatedAtString() -> String {
        
        if let updatedAt = tracksUpdatedAt {
            let components = NSCalendar.currentCalendar().components(.Day, fromDate: updatedAt, toDate: NSDate(), options: .WrapComponents)
            
            var result = "Updated: "
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            if dateFormatter.stringFromDate(updatedAt).containsString(":00"){
                dateFormatter.dateFormat = "ha"
            }
            result += dateFormatter.stringFromDate(updatedAt).lowercaseString
            result += ", "
            
            if components.day == 0 {
                result += "today"
            } else if components.day == 1 {
                result += "yesterday"
            } else {
                result += String(format: "%i days ago", components.day)
            }
            return result
            
        } else {
            return ""
        }
    }
}
