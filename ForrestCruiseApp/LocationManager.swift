//
//  LocationManager.swift
//  ForrestCruiseApp
//
//  Created by Daniel Sauble on 8/18/16.
//  Copyright © 2016 Daniel Sauble. All rights reserved.
//

import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    var deferringUpdates: Bool = false
    var callback: ((locations: [CLLocation]) -> Void)?
    
    override init() {
        
        super.init()
        
        // Set up the location manager
        self.locationManager.delegate = self
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        self.locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
        self.locationManager.activityType = CLActivityType.Fitness
        //self.locationManager.pausesLocationUpdatesAutomatically = false
        
        // Check authorization. Request location services.
        if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedAlways {
            self.locationManager.requestAlwaysAuthorization()
        }
        else {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    // Start capturing data
    func startCapture() {
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = kCLLocationAccuracyBest
    }
    
    // Stop capturing data
    func stopCapture() {
        self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        self.locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
    }
    
    // MARK: CLLocationManagerDelegate
    
    // Location services authorization changed, start updating the location
    @objc func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status != CLAuthorizationStatus.AuthorizedAlways {
            //fatalError("Did not receive permission to capture location")
        }
        else {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    // Record the current location
    @objc func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        // Add the new points to the array
        if let cb = callback {
            cb(locations: locations)
        }
        
        // Defer updates when the app is backgrounded
        if !self.deferringUpdates {
            self.locationManager.allowDeferredLocationUpdatesUntilTraveled(CLLocationDistanceMax, timeout: CLTimeIntervalMax)
            self.deferringUpdates = true
        }
    }
    
    // Turn off the deferringUpdates flag
    @objc func locationManager(manager: CLLocationManager, didFinishDeferredUpdatesWithError error: NSError?) {
        self.deferringUpdates = false
    }
}