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
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        id                  <- map["id"]
        name                <- map["name"]
        shortDescription    <- map["short_description"]
    }

}
