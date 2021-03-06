//
//  Station.swift
//  Stationdose
//
//  Created by Developer on 11/26/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//
//
//import Foundation
//import ObjectMapper
//
//class SavedStation: Mappable {
//    var id:Int?
//    var undergroundness:Int?
//    var useWeather:Bool?
//    var useTimeofday:Bool?
//    var station:Station?
//    var tracks:[Track]?
//    var updatedAt:NSDate? {
//        get {
//            return NSUserDefaults.standardUserDefaults().objectForKey(String(format: "SavedStationUpdatedAtFor_%i", (id != nil) ? id! : 0)) as? NSDate
//        }
//        set {
//            if let newValue = newValue {
//                NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: String(format: "SavedStationUpdatedAtFor_%i", (id != nil) ? id! : 0))
//                NSUserDefaults.standardUserDefaults().synchronize()
//            }
//        }
//    }
//    
//    required init?(_ map: Map) {
//    }
//    
//    func mapping(map: Map) {
//        id                  <- map["id"]
//        undergroundness     <- map["undergroundness"]
//        useWeather          <- map["use_weather"]
//        useTimeofday        <- map["use_timeofday"]
//        station             <- map["station"]
//        updatedAt           <- (map["updated_at"], ISO8601DateTransform())
//    }
//    
//    func toggleWeather(){
//        if let weather =  useWeather{
//            useWeather = !weather
//        }else{
//            useWeather = true
//        }
//    }
//    
//    func toggleTime(){
//        if let time =  useTimeofday{
//            useTimeofday = !time
//        }else{
//            useTimeofday = true
//        }
//    }
//    
//    func updatedAtString() -> String {
//        
//        if let updatedAt = updatedAt {
//            let components = NSCalendar.currentCalendar().components(.Day, fromDate: updatedAt, toDate: NSDate(), options: .WrapComponents)
//            
//            var result = "Updated: "
//            let dateFormatter = NSDateFormatter()
//            dateFormatter.dateFormat = "hh:mm a"
//            if dateFormatter.stringFromDate(updatedAt).containsString(":00"){
//                dateFormatter.dateFormat = "ha"
//            }
//            result += dateFormatter.stringFromDate(updatedAt).lowercaseString
//            result += ", "
//            
//            if components.day == 0 {
//                result += "today"
//            } else if components.day == 1 {
//                result += "yesterday"
//            } else {
//                result += String(format: "%i days ago", components.day)
//            }
//            return result
//            
//        } else {
//            return ""
//        }
//    }
//}
