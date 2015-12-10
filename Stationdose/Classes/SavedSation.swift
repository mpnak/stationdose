//
//  Station.swift
//  Stationdose
//
//  Created by Developer on 11/26/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import Foundation
import ObjectMapper

class SavedStation: Mappable {
    var id:Int?
    var undergroundness:Int?
    var useWeather:Bool?
    var useTimeofday:Bool?
    var autoupdate:Bool?
    var station:Station?
    var tracks:[Track]?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        id                  <- map["id"]
        undergroundness     <- map["undergroundness"]
        useWeather          <- map["use_weather"]
        useTimeofday        <- map["use_timeofday"]
        autoupdate          <- map["autoupdate"]
        station             <- map["station"]
    }
}
