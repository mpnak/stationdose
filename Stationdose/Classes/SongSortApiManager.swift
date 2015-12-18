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
import netfox

enum SongSortApiManagerNotificationKey: String {
    case SavedStationDidChangeUpdatedAt
}

class SongSortApiManager {
    
    static let sharedInstance = SongSortApiManager()
    var manager: Manager
    var baseURL: String
    
    struct ApiMethods{
        static let stationsList = "stations"
        static let savedStations = "users/%i/saved_stations"
        static let savedStation = "saved_stations/%i"
        static let stationTraks = "stations/%i/tracks"
        static let savedStationTraks = "saved_stations/%i/tracks"
        static let playTrack = "tracks/%i/play"
        static let skipTrack = "tracks/%i/skipped"
        static let favoriteTrack = "tracks/%i/favorited"
        static let unfavoriteTrack = "tracks/%i/unfavorited"
        static let banTrack = "tracks/%i/banned"
        static let renewSession = "spotify/sessions"
    }
    
    init() {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForRequest = 10 // seconds
        configuration.protocolClasses?.insert(NFXProtocol.self, atIndex: 0)
        
        self.manager = Manager(configuration: configuration)
        self.baseURL = Constants.SognSort.baseDevelopmentUrl
    }
    
    func getStations(onCompletion:([Station]?,NSError?) -> Void) {
        manager.request(.GET, baseURL+ApiMethods.stationsList).responseArray("stations") { (response: Response<[Station], NSError>) in
            self.showGenericErrorIfNeeded(response.result.error)
            onCompletion(response.result.value, response.result.error)
        }
    }
    
    func getSavedStations(onCompletion:([SavedStation]?,NSError?) -> Void) {
        guard let user = ModelManager.sharedInstance.user
            else{
                self.showGenericErrorIfNeeded(NSError(domain: "No User", code: 0, userInfo: nil))
                onCompletion(nil, NSError(domain: "No User", code: 0, userInfo: nil))
                return
        }
        manager.request(.GET, String(format:baseURL+ApiMethods.savedStations,user.id!)).responseArray("saved_stations") { (response: Response<[SavedStation], NSError>) in
            self.showGenericErrorIfNeeded(response.result.error)
            onCompletion(response.result.value, response.result.error)
        }
    }
    
    func saveStation(stationId:Int, onCompletion:(SavedStation?,NSError?) -> Void) {
        guard let user = ModelManager.sharedInstance.user
        else{
            self.showGenericErrorIfNeeded(NSError(domain: "No User", code: 0, userInfo: nil))
            onCompletion(nil, NSError(domain: "No User", code: 0, userInfo: nil))
            return
        }
        let data = ["saved_station": ["user_id": user.id!, "station_id": stationId]]
        manager.request(.POST, String(format:baseURL+ApiMethods.savedStations,user.id!), parameters:data).responseObject("saved_station") { (response: Response<SavedStation, NSError>) -> Void in
            self.showGenericErrorIfNeeded(response.result.error)
            onCompletion(response.result.value, response.result.error)
        }
    }
    
    func updateSavedStation(savedStation:SavedStation,onCompletion:(SavedStation?,NSError?) -> Void) {
        guard let _ = ModelManager.sharedInstance.user
            else{
                self.showGenericErrorIfNeeded(NSError(domain: "No User", code: 0, userInfo: nil))
                onCompletion(nil, NSError(domain: "No User", code: 0, userInfo: nil))
                return
        }
        var indicators = [String:AnyObject]()
        if let undergroundness = savedStation.undergroundness{
            indicators["undergroundness"] = undergroundness
        }
        if let useWeather = savedStation.useWeather{
            indicators["use_weather"] = useWeather
        }
        if let useTime = savedStation.useTimeofday{
            indicators["use_timeofday"] = useTime
        }
        if let autoupdate = savedStation.useTimeofday{
            indicators["autoupdate"] = autoupdate
        }
        let data = ["saved_station": indicators]
        manager.request(.PUT, String(format:baseURL+ApiMethods.savedStation,savedStation.id!), parameters:data).responseObject("saved_station") { (response: Response<SavedStation, NSError>) -> Void in
            self.showGenericErrorIfNeeded(response.result.error)
            onCompletion(response.result.value, response.result.error)
        }
    }
    
    func removeSavedStation(savedStationId:Int) {
        manager.request(.DELETE, baseURL+String(format: ApiMethods.savedStation, savedStationId))
    }
    
    func generateSavedStationTracks(savedStation:SavedStation, onCompletion:([Track]?,NSError?) -> Void) {
        guard let user = ModelManager.sharedInstance.user
            else{
                self.showGenericErrorIfNeeded(NSError(domain: "No User", code: 0, userInfo: nil))
                onCompletion(nil, NSError(domain: "No User", code: 0, userInfo: nil))
                return
        }
        
        
        
        var data:Dictionary<String,AnyObject> = ["user_id": user.id!]
        if let location = LocationManager.sharedInstance.currentLocation{
            data["ll"] = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
        }
        manager.request(.POST, baseURL+String(format: ApiMethods.savedStationTraks, savedStationId),parameters:data).responseArray("tracks") { (response: Response<[Track], NSError>) in
            self.showGenericErrorIfNeeded(response.result.error)
            onCompletion(response.result.value, response.result.error)
            savedStation.updatedAt = NSDate()
            NSNotificationCenter.defaultCenter().postNotificationName(SongSortApiManagerNotificationKey.SavedStationDidChangeUpdatedAt.rawValue, object: savedStation)
        }
    }
    
    func generateStationTracks(stationId:Int, onCompletion:([Track]?,NSError?) -> Void) {
        manager.request(.POST, baseURL+String(format: ApiMethods.stationTraks, stationId)).responseArray("tracks") { (response: Response<[Track], NSError>) in
            self.showGenericErrorIfNeeded(response.result.error)
            onCompletion(response.result.value, response.result.error)
        }
    }
    
    
    func getSavedStationTracks(stationId:Int, onCompletion:([Track]?,NSError?) -> Void) {
        guard let user = ModelManager.sharedInstance.user
            else{
                self.showGenericErrorIfNeeded(NSError(domain: "No User", code: 0, userInfo: nil))
                onCompletion(nil, NSError(domain: "No User", code: 0, userInfo: nil))
                return
        }
        let data = ["user_id": user.id!]
        manager.request(.GET, baseURL+String(format: ApiMethods.savedStationTraks, stationId),parameters:data).responseArray("tracks") { (response: Response<[Track], NSError>) in
            self.showGenericErrorIfNeeded(response.result.error)
            onCompletion(response.result.value, response.result.error)
        }
    }
    
    func getStationTracks(stationId:Int, onCompletion:([Track]?,NSError?) -> Void) {
        manager.request(.GET, baseURL+String(format: ApiMethods.stationTraks, stationId)).responseArray("tracks") { (response: Response<[Track], NSError>) in
            self.showGenericErrorIfNeeded(response.result.error)
            onCompletion(response.result.value, response.result.error)
        }
    }
    
    func playTrack(playlistId:Int,trackId:Int) {
        manager.request(.POST, baseURL+String(format: ApiMethods.playTrack,trackId))
    }
    
    func skipTrack(playlistId:Int,trackId:Int) {
        manager.request(.POST, baseURL+String(format: ApiMethods.skipTrack,trackId))
    }
    
    func unfavoriteTrack(stationId:Int,savedStationId:Int,trackId:Int) {
        guard let user = ModelManager.sharedInstance.user
            else{
                return
        }
        let data = ["user_id": user.id!,"station_id":stationId,"saved_station_id":savedStationId]
        manager.request(.POST, baseURL+String(format: ApiMethods.unfavoriteTrack,trackId),parameters:data)
    }
    
    func favoriteTrack(stationId:Int,savedStationId:Int,trackId:Int) {
        guard let user = ModelManager.sharedInstance.user
            else{
                return
        }
        let data = ["user_id": user.id!,"station_id":stationId,"saved_station_id":savedStationId]
        manager.request(.POST, baseURL+String(format: ApiMethods.favoriteTrack,trackId),parameters:data)
    }
    
    
    func banTrack(stationId:Int,savedStationId:Int,trackId:Int) {
        guard let user = ModelManager.sharedInstance.user
            else{
                return
        }
        let data = ["user_id": user.id!,"station_id":stationId,"saved_station_id":savedStationId]
        manager.request(.POST, baseURL+String(format: ApiMethods.banTrack,trackId),parameters:data)
    }
    
    func renewSession(spotifyToken:String,onCompletion:(User?,NSError?) -> Void){
        let data = ["access_token": spotifyToken]
        manager.request(.POST, baseURL+ApiMethods.renewSession, parameters:data).responseObject("user") { (response: Response<User, NSError>) -> Void in
            if let token = response.result.value?.accessToken{
                self.manager.session.configuration.HTTPAdditionalHeaders = ["AUTHORIZATION": token]
            }
            self.showGenericErrorIfNeeded(response.result.error)
            onCompletion(response.result.value, response.result.error)
            
        }
    }
    
    func showGenericErrorIfNeeded(error:NSError?){
        if let _ = error{
           AlertView.genericErrorAlert().show()
        }

    }
}
