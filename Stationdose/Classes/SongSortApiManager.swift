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
    case StationDidChangeUpdatedAt
}

class SongSortApiManager {
    
    static let sharedInstance = SongSortApiManager()
    var manager: Manager
    var baseURL: String
    
    struct ApiMethods{
        static let stations = "stations"
        static let stationsPlaylistProfileChooser = "stations/playlist_profile_chooser"
        static let station = "stations/%i"
        static let stationTracks = "stations/%i/tracks"
        static let playTrack = "tracks/%i/play"
        static let skipTrack = "tracks/%i/skipped"
        static let favoriteTrack = "tracks/%i/favorited"
        static let unfavoriteTrack = "tracks/%i/unfavorited"
        static let banTrack = "tracks/%i/banned"
        static let renewSession = "spotify/sessions"
    }
    
    init() {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForRequest = 20 // seconds
        configuration.protocolClasses?.insert(NFXProtocol.self, atIndex: 0)
        self.manager = Manager(configuration: configuration)
        self.baseURL = Constants.SongSort.baseUrl
    }
    
    func getStations(onCompletion:([Station]?,NSError?) -> Void) {
        guard let _ = ModelManager.sharedInstance.user
            else{
                self.showGenericErrorIfNeeded(NSError(domain: "No User", code: 0, userInfo: nil))
                onCompletion(nil, NSError(domain: "No User", code: 0, userInfo: nil))
                return
        }
        
        manager.request(.GET, baseURL+ApiMethods.stations).responseArray("stations") { (response: Response<[Station], NSError>) in
            self.showGenericErrorIfNeeded(response.result.error)
            onCompletion(response.result.value, response.result.error)
        }
    }
    
    func getPlaylistProfiles(onCompletion:(PlaylistProfileChooser?, NSError?) -> Void) {
        guard let _ = ModelManager.sharedInstance.user
            else{
                self.showGenericErrorIfNeeded(NSError(domain: "No User", code: 0, userInfo: nil))
                onCompletion(nil, NSError(domain: "No User", code: 0, userInfo: nil))
                return
        }
        
        manager.request(.GET, baseURL+ApiMethods.stationsPlaylistProfileChooser).responseObject("playlist_profile_chooser") { (response: Response<PlaylistProfileChooser, NSError>) in
            self.showGenericErrorIfNeeded(response.result.error)
            onCompletion(response.result.value, response.result.error)
        }
    }
    
    func saveStation(stationId:Int, onCompletion:(Station?,NSError?) -> Void) {
        guard let _ = ModelManager.sharedInstance.user
            else{
                self.showGenericErrorIfNeeded(NSError(domain: "No User", code: 0, userInfo: nil))
                onCompletion(nil, NSError(domain: "No User", code: 0, userInfo: nil))
                return
        }
        let data = ["station": ["saved_station": true]]
        manager.request(.PUT, String(format:baseURL+ApiMethods.station, stationId), parameters:data).responseObject("station") { (response: Response<Station, NSError>) -> Void in
            self.showGenericErrorIfNeeded(response.result.error)
            onCompletion(response.result.value, response.result.error)
        }
    }
    
    func updateStation(station:Station,onCompletion:(Station?,NSError?) -> Void) {
        guard let _ = ModelManager.sharedInstance.user
            else{
                self.showGenericErrorIfNeeded(NSError(domain: "No User", code: 0, userInfo: nil))
                onCompletion(nil, NSError(domain: "No User", code: 0, userInfo: nil))
                return
        }
        var indicators = [String:AnyObject]()
        if let undergroundness = station.undergroundness{
            indicators["undergroundness"] = undergroundness
        }
        let data = ["station": indicators]
        manager.request(.PUT, String(format:baseURL+ApiMethods.station,station.id!), parameters:data).responseObject("station") { (response: Response<Station, NSError>) -> Void in
            self.showGenericErrorIfNeeded(response.result.error)
            onCompletion(response.result.value, response.result.error)
        }
    }

    
    func removeSavedStation(stationId: Int) {
        guard let _ = ModelManager.sharedInstance.user else {
            self.showGenericErrorIfNeeded(NSError(domain: "No User", code: 0, userInfo: nil))
            return
        }
        let data = ["station": ["saved_station": false]]
        manager.request(.PUT, String(format:baseURL+ApiMethods.station, stationId), parameters:data).responseObject("station") { (response: Response<Station, NSError>) -> Void in
             self.showGenericErrorIfNeeded(response.result.error)
        }
    }
    
    func getStationTracks(stationId: Int, onCompletion: (Station?, NSError?) -> Void) {
        manager.request(.GET, baseURL+String(format: ApiMethods.stationTracks, stationId)).responseObject("station") { (response: Response<Station, NSError>) in
            let str = NSString(data: response.data!, encoding: NSUTF8StringEncoding)
            print(str)
            print(response)
            self.showGenericErrorIfNeeded(response.result.error)
            onCompletion(response.result.value, response.result.error)
        }
        
//        manager.request(.GET, baseURL+String(format: ApiMethods.stationTracks, stationId)).responseArray("tracks") { (response: Response<[Track], NSError>) in
//            let str = NSString(data: response.data!, encoding: NSUTF8StringEncoding)
//            print(str)
//            print(response)
//            self.showGenericErrorIfNeeded(response.result.error)
//            onCompletion(response.result.value, response.result.error)
//        }
    }
    
    func generateStationTracks(station: Station, onCompletion:(Station?,NSError?) -> Void) {
        guard let _ = ModelManager.sharedInstance.user else {
            self.showGenericErrorIfNeeded(NSError(domain: "No User", code: 0, userInfo: nil))
            onCompletion(nil, NSError(domain: "No User", code: 0, userInfo: nil))
            return
        }
        
        var data = [String: AnyObject]()
        if let location = LocationManager.sharedInstance.currentLocation{
            data["ll"] = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
        }
        manager.request(
            .POST,
            baseURL+String(format: ApiMethods.stationTracks, station.id!),
            parameters:data
        ).responseObject("station") { (response: Response<Station, NSError>) in
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

    func unfavoriteTrack(stationId: Int, trackId: Int) {
        guard let _ = ModelManager.sharedInstance.user else { return }
        let data = ["station_id": stationId]
        manager.request(.POST, baseURL+String(format: ApiMethods.unfavoriteTrack, trackId), parameters: data)
    }
    
    func favoriteTrack(stationId: Int, trackId: Int) {
        guard let _ = ModelManager.sharedInstance.user else { return }
        let data = ["station_id": stationId]
        manager.request(.POST, baseURL+String(format: ApiMethods.favoriteTrack, trackId), parameters: data)
    }
    
    
    func banTrack(stationId: Int, trackId: Int) {
        guard let _ = ModelManager.sharedInstance.user else { return }
        let data = ["station_id": stationId]
        manager.request(.POST, baseURL+String(format: ApiMethods.banTrack, trackId), parameters: data)
    }
    
    func renewSession(spotifyToken:String,onCompletion:(User?,NSError?) -> Void){
        let data = ["access_token": spotifyToken]
        manager.request(.POST, baseURL+ApiMethods.renewSession, parameters:data).responseObject("user") { (response: Response<User, NSError>) -> Void in
            if let token = response.result.value?.accessToken{
                let configuration = self.manager.session.configuration
                configuration.HTTPAdditionalHeaders = ["Authorization": "Bearer \(token)" ]
                self.manager = Manager(configuration: configuration)
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
