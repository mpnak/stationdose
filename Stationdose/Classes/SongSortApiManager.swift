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
    var manager: Manager
    var baseURL: String
    
    struct ApiMethods{
        static let stationsList = "stations"
        static let playlists = "users/1/playlists"
        static let playlistsDelete = "playlists/%i"
    }
    
    init() {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForRequest = 10 // seconds
        
        self.manager = Manager(configuration: configuration)
        self.baseURL = Constants.SognSort.baseDevelopmentUrl
    }
    
    func getStationsList(onCompletion:([Station]?,NSError?) -> Void) {
        manager.request(.GET, baseURL+ApiMethods.stationsList).responseArray("stations") { (response: Response<[Station], NSError>) in
            onCompletion(response.result.value,response.result.error)
        }
    }
    
    func getPlaylists(onCompletion:([Playlist]?,NSError?) -> Void) {
        manager.request(.GET, baseURL+ApiMethods.playlists).responseArray("playlists") { (response: Response<[Playlist], NSError>) in
            onCompletion(response.result.value, response.result.error)
        }
    }
    
    func savePlaylist(stationId:Int, onCompletion:(Playlist?,NSError?) -> Void) {
        let data = ["playlist": ["user_id": 1, "station_id": stationId]]
        manager.request(.POST, baseURL+ApiMethods.playlists, parameters:data).responseObject("playlist") { (response: Response<Playlist, NSError>) -> Void in
            onCompletion(response.result.value, response.result.error)
        }
    }
    
    func removePlaylist(playlistId:Int) {
        manager.request(.DELETE, baseURL+String(format: ApiMethods.playlistsDelete, playlistId))
    }
}
