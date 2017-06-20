//
//  LocationHelper.swift
//  FreePhoto
//
//  Created by Le Van Long on 6/21/17.
//  Copyright © 2017 dev.longlv. All rights reserved.
//

import UIKit
import CoreLocation

typealias VoidDelegate = () -> Void

class LocationHelper: NSObject, CLLocationManagerDelegate {
    
    var isUpdateLocation = false
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    var locationUpdated: VoidDelegate?
    var currentDelta: Double = 0.05
    
    func pickLocation(location: CLLocationCoordinate2D, delta: Double) {
        self.currentLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        self.currentDelta = delta
    }
    func requestCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        isUpdateLocation = true
        print("Location requested")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !isUpdateLocation {
            return
        }
        if currentLocation != locations.last {
            isUpdateLocation = false
            currentLocation = locations.last
            locationUpdated?()
            print("Location Updated")
        }
        locationManager.stopUpdatingLocation()
    }
    
    func calculateDistance(latitude: Double, longitude: Double) -> Double {
        if self.currentLocation == nil {
            return 0
        }
        let loc = CLLocation(latitude: latitude, longitude: longitude)
        return loc.distance(from: self.currentLocation!)
    }
}
