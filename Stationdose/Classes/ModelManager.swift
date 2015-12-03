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
    case StationsDidReloadFromServer
    case PlaylistsDidReloadFromServer
    case PlaylistsDidChange
    case AllDataDidReloadFromServer
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
                self.postEvent(.AllDataDidReloadFromServer)
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
                self.postEvent(.PlaylistsDidReloadFromServer)
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
    
    func savePlaylist(station: Station, onCompletion:(saved:Bool) -> Void) {
        SongSortApiManager.sharedInstance.savePlaylist(station.id!) { (playlist, error) -> Void in
            if let playlist = playlist {
                self.playlists.append(playlist)
                
                onCompletion(saved: true)
                self.postEvent(.PlaylistsDidChange)
            } else {
                onCompletion(saved: false)
            }
        }
    }
    
    func removePlaylist(station: Station, callback: (removed:Bool) -> Void) {
        AlertView(title: "Remove Station?", message: "Are you sure you want to remove this station from your favorites", acceptButtonTitle: "Yes", cancelButtonTitle: "Nevermind", callback: { (accept) -> Void in
            if accept {
                let playlistsToDelete = self.playlists.filter() { $0.station!.id == station.id }
                
                for playlistToDelete in playlistsToDelete {
                    SongSortApiManager.sharedInstance.removePlaylist(playlistToDelete.id!)
                }
                self.playlists = self.playlists.filter() { $0.station!.id != station.id }
                
                callback(removed:true)
                self.postEvent(.PlaylistsDidChange)
            } else {
                callback(removed:false)
            }
        }).show()
    }
    
    private func postEvent (notificationKey: ModelManagerNotificationKey) {
        NSNotificationCenter.defaultCenter().postNotificationName(notificationKey.rawValue, object: nil)
    }
}
