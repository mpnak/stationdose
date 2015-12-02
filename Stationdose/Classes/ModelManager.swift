//
//  ModelManager.swift
//  Stationdose
//
//  Created by Developer on 12/2/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit

enum ModelManagerNotificationKey: String {
    case StationsDidChange
    case PlaylistsDidChange
    case SomeDataDidChange
}

class ModelManager: NSObject {
    
    static let sharedInstance = ModelManager()
    
    var playlists: [Playlist]
    var stations: [Station]
    
    override init() {
        playlists = []
        stations = []
        
        super.init()
    }
    
    func initialCache(onCompletion:() -> Void) {
        self.reloadData(onCompletion)
    }
    
    var reloadDataPendingStepsCounter = 0
    func reloadData(onCompletion:() -> Void) {
        
        if reloadDataPendingStepsCounter > 0 {
            return
        }
        
        let stepCompletion = { () -> Void in
            if --self.reloadDataPendingStepsCounter == 0 {
                self.postEvent(.SomeDataDidChange)
                onCompletion()
            }
        }
        
        let reloadClosures = [
            {self.reloadStations(stepCompletion)},
            {self.reloadPlaylists(stepCompletion)} /* add here any other closure needed to reload all the data*/
        ]
        
        reloadDataPendingStepsCounter = reloadClosures.count
        
        for closure in reloadClosures {
            closure()
        }
    }
    
    func reloadPlaylists(onCompletion:() -> Void) {
        SongSortApiManager.sharedInstance.getPlaylists { (playlists, error) -> Void in
            if let playlists = playlists {
                self.playlists = playlists
                self.postEvent(.PlaylistsDidChange)
            }
            onCompletion()
        }
    }
    
    func reloadStations(onCompletion:() -> Void) {
        SongSortApiManager.sharedInstance.getStations { (stations, error) -> Void in
            if let stations = stations {
                self.stations = stations
                self.postEvent(.StationsDidChange)
            }
            onCompletion()
        }
    }
    
    func savePlaylist(stationId:Int, onCompletion:(success:Bool) -> Void) {
        SongSortApiManager.sharedInstance.savePlaylist(stationId) { (playlist, error) -> Void in
            if let playlist = playlist {
                self.playlists.append(playlist)
                self.postEvent(.PlaylistsDidChange)
                onCompletion(success: true)
            } else {
                onCompletion(success: false)
            }
        }
    }
    
    private func postEvent (notificationKey: ModelManagerNotificationKey) {
        NSNotificationCenter.defaultCenter().postNotificationName(notificationKey.rawValue, object: nil)
        if notificationKey != .SomeDataDidChange {
            postEvent(.SomeDataDidChange)
        }
    }
}
