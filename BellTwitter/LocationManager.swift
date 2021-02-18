//
//  LocationManager.swift
//  BellTwitter
//
//  Created by Ronit Banze on 2019-10-05.
//  Copyright © 2019 Ronit Banze. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate, LocationKernelDelegate {
    
    var locationManager : CLLocationManager!
    var locationKernel : LocationKernel!
    
    class var sharedManager : LocationManager {
        struct Static {
            static let instance : LocationManager = LocationManager()
        }
        return Static.instance
    }
    
    private override init() {
        super.init()
    }
    
    /**
    Starts service asks for when in use permission
    */
    func startLocationServices() {
        self.locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 100
        if locationKernel == nil {
            locationKernel = LocationKernel(delegate: self)
        }
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("failed with error")
    }
    
    /**
    LocationKernelDelegate Method
    */
    func getNewLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        let locationAge = -newLocation.timestamp.timeIntervalSinceNow
        
        //this check because it is called sometimes 3-4 times a second creating new instances of my timer
        if locationAge > 1.0 {
            return
        }
        
        if locationKernel != nil {
            locationKernel.location = locations.last
            locationKernel.startTimer()
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            
            // If status has not yet been determied, ask for authorization
            locationManager.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse:
            
            // If authorized when in use
            locationManager.startUpdatingLocation()
            break
        default:
            break
        }
    }
    
}
