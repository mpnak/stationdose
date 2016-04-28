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
    case StationsDidChange
    case AllDataDidReloadFromServer
    case StationDidChangeModifiers
    case WillStartStationTracksReGeneration
    case DidEndStationTracksReGeneration
}

class ModelManager: NSObject {
    
    static let sharedInstance = ModelManager()
    
    var savedStations: [Station]
    var stations: [Station]
    var sponsoredStations: [Station]
    var featuredStations: [Station]
    var user:User?
    let imageDownloader = ImageDownloader.defaultInstance
    
    override init() {
        savedStations = []
        stations = []
        featuredStations = []
        sponsoredStations = []
        
        super.init()
    }
    
    func initialCache(onCompletion:() -> Void) {
        self.reloadData(onCompletion)
    }
    
    func reloadCache(onCompletion:() -> Void) {
        if let _ = user{
            self.reloadData(onCompletion)
        }
    }
    
    /**
     If a stations tracks are empty then try to getStationTracks them from the server. If that reponse is empty then generateStationTracks
    */
    func reloadNotCachedStationTracksAndCache(station: Station, onCompletion: () -> Void){
        if(station.tracks == nil) {
            postEvent(.WillStartStationTracksReGeneration, id: station.id!)
            SongSortApiManager.sharedInstance.getStationTracks((station.id)!, onCompletion: { (_station, error) -> Void in
                if _station != nil && (_station!.tracks == nil || _station!.tracks!.isEmpty) {
                    SongSortApiManager.sharedInstance.generateStationTracks(station, onCompletion: { (_station, error) -> Void in
                        self.handleFetchedTracks(station, stationWithTracks: _station, onCompletion: onCompletion)
                    })
                } else {
                    self.handleFetchedTracks(station, stationWithTracks: _station, onCompletion: onCompletion)
                }
            })
        } else {
            onCompletion()
        }
    }
    
    func forceGenerateStationTracks(station: Station, onCompletion: () -> Void){
        postEvent(.WillStartStationTracksReGeneration, id: station.id!)
        SongSortApiManager.sharedInstance.generateStationTracks(station, onCompletion: { (_station, error) -> Void in
            self.handleFetchedTracks(station, stationWithTracks: _station, onCompletion: onCompletion)
        })
    }
    
    func handleFetchedTracks(station: Station, stationWithTracks: Station?, onCompletion: () -> Void) {
        station.tracks = stationWithTracks?.tracks
        station.tracksUpdatedAt = stationWithTracks?.tracksUpdatedAt
        self.stationDidReloadTracks(station)
        self.postEvent(.DidEndStationTracksReGeneration, id: station.id!)
        onCompletion()
    }
    
    func requestStationsFeaturedSponsoredImages(onCompletion:() -> Void){
        
        let requestImage = { (station:Station)->NSURLRequest? in
            if let artUrl = station.art{
                return  NSURLRequest(URL: NSURL(string: artUrl)!)
                
            } else {
                return nil
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
            onCompletion()
            return
        }
        
        let stepCompletion = { () -> Void in
            self.reloadDataPendingStepsCounter -= 1
            if self.reloadDataPendingStepsCounter == 0 {
                self.postEvent(.AllDataDidReloadFromServer)
                onCompletion()
            }
        }
        
        let reloadClosures = [
            {self.reloadStations(stepCompletion)},
            //{self.reloadSavedStations(stepCompletion)} /* add here any other closure needed to reload all the data*/
        ]
        
        reloadDataPendingStepsCounter = reloadClosures.count
        
        for closure in reloadClosures {
            closure()
        }
    }
    
    func reloadStations(onCompletion:() -> Void) {
        SongSortApiManager.sharedInstance.getStations { (stations, error) -> Void in
            if let stations = stations {
                self.stations = stations.filter{ $0.type == "standard" }
                self.featuredStations = stations.filter{ $0.type == "featured" }
                self.sponsoredStations = stations.filter{ $0.type == "sponsored" }
                self.savedStations = stations.filter{ $0.savedStation == true }
                self.postEvent(.StationsDidReloadFromServer)
            }
            self.requestStationsFeaturedSponsoredImages(onCompletion)
        }
    }
    
    func updateStationAndRegenerateTracksIfNeeded(station: Station, regenerateTracks: Bool, onCompletion: () -> Void) {
        
        NSNotificationCenter.defaultCenter().postNotificationName(ModelManagerNotificationKey.StationDidChangeModifiers.rawValue, object: station)
        
        if regenerateTracks {
            postEvent(.WillStartStationTracksReGeneration, id: station.id!)
        }
        SongSortApiManager.sharedInstance.updateStation(station) { (newStation, error) -> Void in
            if let newStation = newStation {
                for (index, toChangeStation) in self.savedStations.enumerate() {
                    if toChangeStation.id == station.id{
                        self.savedStations[index] = toChangeStation
                    }
                }
                if(regenerateTracks){
                    SongSortApiManager.sharedInstance.generateStationTracks(newStation, onCompletion: { (_station, error) -> Void in
                        self.handleFetchedTracks(station, stationWithTracks: _station, onCompletion: onCompletion)
                    })
                } else {
                    onCompletion()
                }
            } else {
                onCompletion()
            }
        }
    }
    
    func saveStation(station: Station, onCompletion: (saved:Bool, savedStation: Station?) -> Void) {
        SongSortApiManager.sharedInstance.saveStation(station.id!) { (savedStation, error) -> Void in
            if let savedStation = savedStation {
                savedStation.savedStation = true
                self.updateStationAndRegenerateTracksIfNeeded(savedStation, regenerateTracks: false) {
                    self.savedStations.append(savedStation)
                    onCompletion(saved: true, savedStation:savedStation)
                    self.postEvent(.StationsDidChange)
                }
            } else {
                onCompletion(saved: false, savedStation: nil)
            }
        }
    }
    
    func removeSavedStation(stationToDelete: Station, callback: (removed:Bool) -> Void) {
        AlertView(title: "Remove Station?", message: "Are you sure you want to remove this station from your favorites?", acceptButtonTitle: "Yes", cancelButtonTitle: "Nevermind", callback: { (accept) -> Void in
            if accept {
                SongSortApiManager.sharedInstance.removeSavedStation(stationToDelete.id!)
                self.savedStations = self.savedStations.filter() { $0.id != stationToDelete.id }
                callback(removed:true)
                self.postEvent(.StationsDidChange)
            } else {
                callback(removed:false)
            }
        }).show()
    }
    
    private func postEvent (notificationKey: ModelManagerNotificationKey) {
        NSNotificationCenter.defaultCenter().postNotificationName(notificationKey.rawValue, object: nil)
    }
    
    private func postEvent(notificationKey: ModelManagerNotificationKey, id:Int ) {
        let myDict = [ "id": id]
        NSNotificationCenter.defaultCenter().postNotificationName(notificationKey.rawValue, object: myDict)
    }
    
    private func stationDidReloadTracks(station:Station) {
        if let tracks = station.tracks {
            PlaybackManager.sharedInstance.replaceQueue(tracks)
        }

    }
}
