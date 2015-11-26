//
//  Station.swift
//  Stationdose
//
//  Created by Developer on 11/26/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import Foundation
import ObjectMapper

class Track: Mappable {
    var id:Int?
    var spotifyId:String?
    var echoNestId:String?
    var title:String?
    var artist:String?
    var undergroundness:String?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        id                  <- map["id"]
        spotifyId           <- map["spotify_id"]
        echoNestId          <- map["echo_nest_id"]
        title               <- map["title"]
        artist              <- map["artist"]
        undergroundness     <- map["undergroundness"]
    }

}
