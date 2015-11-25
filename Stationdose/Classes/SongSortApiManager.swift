//
//  SongSortApiManager.swift
//  Stationdose
//
//  Created by Developer on 11/25/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper

class SongSortApiManager {
    
    static let sharedInstance = SongSortApiManager()
    var manager:Manager
    var baseURL: String
    
    let stationsEndPoint = "stations"
    
    init(){
        
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForRequest = 10 // seconds
        
        self.manager = Manager(configuration: configuration)
        self.baseURL = Constants.SognSort.baseDevelopmentUrl
        
        
    }
    
    typealias stationsResponse = ([Station]?,NSError?) -> Void
    
    func getAllStations(onCompletion:stationsResponse){
        manager.request(.GET, baseURL+stationsEndPoint).responseArray("stations") { (response: Response<[Station], NSError>) in
            
            onCompletion(response.result.value,response.result.error)
            
        }
        
    }
    /*
    func getMyStations(onCompletion:stationsResponse){
        manager.request(.GET, baseURL+stationsEndPoint).responseArray("stations") { (response: Response<[Station], NSError>) in
            
            onCompletion(response.result.value,response.result.error)
            
            
        }
        
    }*/
}
