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
    case SavedStationsDidReloadFromServer
    case SavedStationsDidChange
    case AllDataDidReloadFromServer
    case WillStartSavedStationTracksReGeneration
    case DidEndSavedStationTracksReGeneration
    case SavedStationDidChangeModifiers
    case WillStartStationTracksReGeneration
    case DidEndStationTracksReGeneration
    
}

class ModelManager: NSObject {
    
    static let sharedInstance = ModelManager()
    
    var savedStations: [SavedStation]
    var stations: [Station]
    var sponsoredStations: [Station]
    var featuredStations: [Station]
    var user:User?
    let imageDownloader = ImageDownloader.defaultInstance
    
    var onNexStationSaveUseWeather: Bool
    var onNexStationSaveUseTime: Bool
    
    override init() {
        savedStations = []
        stations = []
        featuredStations = []
        sponsoredStations = []
        onNexStationSaveUseWeather = false
        onNexStationSaveUseTime = false
        
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
    
    // TODO cleanup
//    func generateAutomatedSavedStationsTracksAndCache(savedStations:[SavedStation],onCompletion:() -> Void){
//        
//        let group = dispatch_group_create()
//        
//        savedStations.forEach { (savedStation) -> () in
//            if let autoupdate = savedStation.autoupdate where autoupdate == true {
//                dispatch_group_enter(group)
//                postEvent(.WillStartSavedStationTracksReGeneration, id: savedStation.id!)
//                SongSortApiManager.sharedInstance.generateSavedStationTracks(savedStation, onCompletion: { (tracks, error) -> Void in
//                    savedStation.tracks = tracks;
//                    savedStation.updatedAt = NSDate()
//                    NSNotificationCenter.defaultCenter().postNotificationName(SongSortApiManagerNotificationKey.SavedStationDidChangeUpdatedAt.rawValue, object: savedStation)
//                    self.savedStationDidReloadTracks(savedStation)
//                    self.postEvent(.DidEndSavedStationTracksReGeneration, id: savedStation.id!)
//                    dispatch_group_leave(group)
//                })
//            }
//        }
//        dispatch_group_notify(group, dispatch_get_main_queue()) {
//            onCompletion()
//        }
//    }
    
    func reloadNotCachedSavedStationTracksAndCache(savedStation:SavedStation,onCompletion:() -> Void){
        if(savedStation.tracks == nil){
            SongSortApiManager.sharedInstance.getSavedStationTracks((savedStation.id)!, onCompletion: { (tracks, error) -> Void in
                savedStation.tracks = tracks;
                savedStation.updatedAt = NSDate()
                self.savedStationDidReloadTracks(savedStation)
                self.postEvent(.DidEndSavedStationTracksReGeneration, id: savedStation.id!)
                onCompletion()
            })
        } else {
            onCompletion()
        }
    }
    
    func generateStationTracksAndCache(station:Station,onCompletion:() -> Void){
        if(station.isPlaying == nil || !station.isPlaying!){
           postEvent(.WillStartStationTracksReGeneration, id: station.id!)
            SongSortApiManager.sharedInstance.generateStationTracks((station.id)!, onCompletion: { (tracks, error) -> Void in
                station.tracks = tracks;
                 NSNotificationCenter.defaultCenter().postNotificationName(ModelManagerNotificationKey.WillStartStationTracksReGeneration.rawValue, object: station)
                self.stationDidReloadTracks(station)
                self.postEvent(.DidEndStationTracksReGeneration, id: station.id!)
                onCompletion()
            })
        } else {
            onCompletion()
        }
    }
    
//    func forceGenerateStationTracks(station: Station, onCompletion:() -> Void){
//        postEvent(.StationsDidReloadFromServer)
//    }
    
    func forceGenerateSavedStationTracks(savedStation:SavedStation,onCompletion:() -> Void){
        postEvent(.WillStartSavedStationTracksReGeneration, id: savedStation.id!)
        SongSortApiManager.sharedInstance.generateSavedStationTracks(savedStation, onCompletion: { (tracks, error) -> Void in
            savedStation.tracks = tracks
            savedStation.updatedAt = NSDate()
            NSNotificationCenter.defaultCenter().postNotificationName(SongSortApiManagerNotificationKey.SavedStationDidChangeUpdatedAt.rawValue, object: savedStation)
            self.savedStationDidReloadTracks(savedStation)
            self.postEvent(.DidEndSavedStationTracksReGeneration, id: savedStation.id!)
            onCompletion()
        })
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
            if --self.reloadDataPendingStepsCounter == 0 {
                self.postEvent(.AllDataDidReloadFromServer)
                onCompletion()
            }
        }
        
        let reloadClosures = [
            {self.reloadStations(stepCompletion)},
            {self.reloadSavedStations(stepCompletion)} /* add here any other closure needed to reload all the data*/
        ]
        
        reloadDataPendingStepsCounter = reloadClosures.count
        
        for closure in reloadClosures {
            closure()
        }
    }
    
    func reloadSavedStations(onCompletion:() -> Void) {
        SongSortApiManager.sharedInstance.getSavedStations { (savedStations, error) -> Void in
            if let savedStations = savedStations {
                self.savedStations = savedStations
                self.postEvent(.SavedStationsDidReloadFromServer)
            }
            // TODO cleanup
            //self.generateAutomatedSavedStationsTracksAndCache(self.savedStations, onCompletion: onCompletion)
            onCompletion()
        }
    }
    
    func reloadStations(onCompletion:() -> Void) {
        SongSortApiManager.sharedInstance.getStations { (stations, error) -> Void in
            if let stations = stations {
                self.stations = stations.filter{ $0.type == "standard" }
                self.featuredStations = stations.filter{ $0.type == "featured" }
                self.sponsoredStations = stations.filter{ $0.type == "sponsored" }
                self.postEvent(.StationsDidReloadFromServer)
            }
            self.requestStationsFeaturedSponsoredImages(onCompletion)
        }
    }
    
    func updateSavedStationAndRegenerateTracksIfNeeded(savedStation: SavedStation,regenerateTracks:Bool, onCompletion:() -> Void) {
        
        NSNotificationCenter.defaultCenter().postNotificationName(ModelManagerNotificationKey.SavedStationDidChangeModifiers.rawValue, object: savedStation)
        
        if regenerateTracks {
            postEvent(.WillStartSavedStationTracksReGeneration, id: savedStation.id!)
        }
        SongSortApiManager.sharedInstance.updateSavedStation(savedStation) { (newSavedStation, error) -> Void in
            if let newSavedStation = newSavedStation {
                for (index, toChangeSavedStation) in self.savedStations.enumerate() {
                    if toChangeSavedStation.id == savedStation.id{
                        self.savedStations[index] = toChangeSavedStation
                    }
                }
                if(regenerateTracks){
                    SongSortApiManager.sharedInstance.generateSavedStationTracks(newSavedStation, onCompletion: { (tracks, error) -> Void in
                        savedStation.tracks = tracks;
                        savedStation.updatedAt = NSDate()
                        self.savedStationDidReloadTracks(savedStation)
                        self.postEvent(.DidEndSavedStationTracksReGeneration, id: newSavedStation.id!)
                        onCompletion()
                    })
                } else {
                    onCompletion()
                }
            } else {
                onCompletion()
            }
        }
    }
    
    func saveStation(station: Station, onCompletion:(saved:Bool, savedStation:SavedStation?) -> Void) {
        SongSortApiManager.sharedInstance.saveStation(station.id!) { (savedStation, error) -> Void in
            if let savedStation = savedStation {
                if self.onNexStationSaveUseWeather || self.onNexStationSaveUseTime {
                    savedStation.useWeather = self.onNexStationSaveUseWeather
                    savedStation.useTimeofday = self.onNexStationSaveUseTime
                    self.updateSavedStationAndRegenerateTracksIfNeeded(savedStation, regenerateTracks: false) {
                        self.savedStations.append(savedStation)
                        onCompletion(saved: true, savedStation:savedStation)
                        self.postEvent(.SavedStationsDidChange)
                    }
                } else {
                    self.savedStations.append(savedStation)
                    onCompletion(saved: true, savedStation:savedStation)
                    self.postEvent(.SavedStationsDidChange)
                }
            } else {
                onCompletion(saved: false, savedStation: nil)
            }
        }
    }
    
    func removeSavedStation(stationToDelete: SavedStation, callback: (removed:Bool) -> Void) {
        AlertView(title: "Remove Station?", message: "Are you sure you want to remove this station from your favorites?", acceptButtonTitle: "Yes", cancelButtonTitle: "Nevermind", callback: { (accept) -> Void in
            if accept {
                SongSortApiManager.sharedInstance.removeSavedStation(stationToDelete.id!)
                self.savedStations = self.savedStations.filter() { $0.id != stationToDelete.id }
                callback(removed:true)
                self.postEvent(.SavedStationsDidChange)
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
    
    private func savedStationDidReloadTracks(savedStation:SavedStation) {
        if let tracks = savedStation.tracks {
            PlaybackManager.sharedInstance.replaceQueue(tracks)
        }
    }
}
