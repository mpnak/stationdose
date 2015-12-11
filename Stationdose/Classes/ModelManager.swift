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
}

class ModelManager: NSObject {
    
    static let sharedInstance = ModelManager()
    
    var savedStations: [SavedStation]
    var stations: [Station]
    var sponsoredStations: [Station]
    var featuredStations: [Station]
    var user:User?
    let imageDownloader = ImageDownloader.defaultInstance
    
    override init() {
        savedStations = []
        stations = []
        featuredStations = [];
        sponsoredStations = [];
        
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
    
    func requestStationsFeaturedSponsoredImages(onCompletion:() -> Void){
        
        let requestImage = { (station:Station)->NSURLRequest? in
            if let artUrl = station.art{
                return  NSURLRequest(URL: NSURL(string: artUrl)!)
                
            } else {
                return nil;
            }
        }
        
        let requestImage2 = { (station:Station)->NSURLRequest? in
            if let url = station.url{
                return  NSURLRequest(URL: NSURL(string: url)!)
                
            } else {
                return nil;
            }
        }
        
        let combinedFeaturedAndSponsored = sponsoredStations + featuredStations
        
        let requests = combinedFeaturedAndSponsored.flatMap(requestImage) + combinedFeaturedAndSponsored.flatMap(requestImage2)
        
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
            self.requestStationsFeaturedSponsoredImages(onCompletion);
            //onCompletion()
        }
    }
    
    func saveStation(station: Station, onCompletion:(saved:Bool) -> Void) {
        SongSortApiManager.sharedInstance.saveStation(station.id!) { (savedStation, error) -> Void in
            if let savedStation = savedStation {
                self.savedStations.append(savedStation)
                
                onCompletion(saved: true)
                self.postEvent(.SavedStationsDidChange)
            } else {
                onCompletion(saved: false)
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
}
