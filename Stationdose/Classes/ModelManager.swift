//
//  ModelManager.swift
//  Stationdose
//
//  Created by Developer on 12/2/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit
import AlamofireImage

enum ModelManagerNotificationKey: String {
    case StationsDidChange
    case PlaylistsDidChange
    case SomeDataDidChange
}

class ModelManager: NSObject {
    
    static let sharedInstance = ModelManager()
    
    var playlists: [Playlist]
    var stations: [Station]
    var sponsoredStations: [Station]
    var featuredStations: [Station]
    let imageDownloader = ImageDownloader.defaultInstance
    
    override init() {
        playlists = []
        stations = []
        featuredStations = [];
        sponsoredStations = [];
        
        super.init()
    }
    
    func initialCache(onCompletion:() -> Void) {
        self.reloadData(onCompletion)
        
    }
    
    func requestStationsFeaturedSponsoredImages(onCompletion:() -> Void){
        
        let requestImage = { (station:Station)->NSURLRequest? in
            if let artUrl = station.art{
                return  NSURLRequest(URL: NSURL(string: artUrl)!)

            }else{
                return nil;
            }
        }
        
        let combinedFeaturedAndSponsored = sponsoredStations + featuredStations
        
        let requests = combinedFeaturedAndSponsored.flatMap(requestImage)
        
        let group = dispatch_group_create()
        

        
        requests.forEach {
            
            dispatch_group_enter(group)
            self.imageDownloader.downloadImage(URLRequest: $0){ response in
                dispatch_group_leave(group)
            }

        }
        
        dispatch_group_notify(group, dispatch_get_main_queue()) {
            onCompletion()
        }

        
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
                self.featuredStations = stations.filter{ $0.type == "featured" }
                self.sponsoredStations = stations.filter{ $0.type == "sponsored" }
                self.postEvent(.StationsDidChange)
            }
            self.requestStationsFeaturedSponsoredImages(onCompletion);
            //onCompletion()
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
