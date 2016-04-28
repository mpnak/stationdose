//
//  LocationManager.swift
//  Stationdose
//
//  Created by Developer on 11/25/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager:NSObject,CLLocationManagerDelegate {
    private var locationManager : CLLocationManager?
    
    var currentLocation:CLLocation?
    
    static let sharedInstance = LocationManager()
    
    typealias CurrentLocationComplete = ((location: CLLocation?, error: NSError?)->())
    private var didFindLocation: CurrentLocationComplete?
    
    
    deinit {
        locationManager?.delegate = nil
        locationManager = nil
    }
    
    private func requestAuthorization(showErrorController:UIViewController){
        switch CLLocationManager.authorizationStatus() {
        case .NotDetermined:
            locationManager?.requestWhenInUseAuthorization()
        case .AuthorizedAlways, .Restricted, .Denied:
            let alertController = UIAlertController(
                title: "Stationdose would like to access your location",
                message: "Go to settings to allow the app to look at your location in order to deliver a more customized playlist.",
                preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "Don't Allow", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: "Settings", style: .Default) { (action) in
                if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
            alertController.addAction(openAction)
            
            showErrorController.presentViewController(alertController, animated: true, completion: nil)
            
        default:
            break
        }
        
    }
    
    private func foundLocation(location: CLLocation?, error: NSError?) {
        //locationManager?.stopUpdatingLocation()
        self.currentLocation = location
        didFindLocation?(location: location, error: error)
        didFindLocation = nil
        //locationManager?.delegate = nil
        //locationManager = nil
    }
    
    //location authorization status changed
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        switch status {
        case .AuthorizedWhenInUse:
            locationManager?.startUpdatingLocation()
        case .Denied:
            foundLocation(nil, error: NSError(domain: self.classForCoder.description(),
                code: 1,
                userInfo: nil))
        default:
            break
        }
    }
    
    internal func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        foundLocation(nil, error: error)
    }
    
    internal func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        foundLocation(location, error: nil)
    }
    
    
    var isEnabled:Bool{
        get{
            switch CLLocationManager.authorizationStatus() {
            case .AuthorizedWhenInUse:
                return true
                
            default:
                return false
            }
        }
    }
    
    func getCurrentLocation(showErrorController:UIViewController, completion: CurrentLocationComplete) {
        didFindLocation = completion
        if locationManager == nil{
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager?.distanceFilter = 5000
        }

        self.requestAuthorization(showErrorController)
    }

}
