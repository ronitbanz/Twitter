//
//  LocationKernel.swift
//  BellTwitter
//
//  Created by Ronit Banze on 2019-10-05.
//  Copyright © 2019 Ronit Banze. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationKernelDelegate {
    func getNewLocation()
}

class LocationKernel: NSObject {
    
    /**
     We set this to location managers last location
    */
    var location : CLLocation?
    
    /**
    Timer reset every 30 seconds
    */
    var timer : Timer?
    var delegate : LocationKernelDelegate!
    
    /**
    Interval to fetch tweets in seconds.
    */
    var interval : Double = 30
    
    init(delegate: LocationKernelDelegate) {
        self.delegate = delegate
    }
    
    /**
    Scheduled Timer
    */
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(LocationKernel.cleanTimer), userInfo: nil, repeats: false)
        
        sendCurrentLocation()
    }
    
    @objc func cleanTimer() {
        timer = nil
        delegate.getNewLocation()
    }
    
    func sendCurrentLocation() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PeriodicCoordinatesSent"), object: nil)
    }
    
}
