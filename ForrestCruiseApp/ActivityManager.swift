//
//  ActivityManager.swift
//  ForrestCruiseApp
//
//  Created by Daniel Sauble on 8/17/16.
//  Copyright © 2016 Daniel Sauble. All rights reserved.
//

import HealthKit
import CoreMotion
import CoreLocation

class ActivityManager {
    
    // MARK: Properties
    
    // Detect activity
    var locationManager: LocationManager
    var activityManager: CMMotionActivityManager
    var runInProgress: Bool = false
    
    // Metadata about the current run
    var route: [CLLocation] = []
    var startDate: NSDate?
    var endDate: NSDate?
    var distance: HKQuantity?
    
    init?() {
        guard CMMotionActivityManager.isActivityAvailable() else {
            return nil
        }
        
        // Start polling for location
        locationManager = LocationManager()
        
        // Start checking for activity
        activityManager = CMMotionActivityManager()
        
        // Set up callbacks
        locationManager.callback = self.addPointsToRoute
        activityManager.startActivityUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: self.handleActivityUpdates)
    }
    
    func handleActivityUpdates(data: CMMotionActivity?) {
        if let data = data {
            // Start recording GPS data
            //if data.stationary && !self.runInProgress {
            if data.confidence == .High && data.running && !self.runInProgress {
                self.startRun()
            }
            // Stop recording GPS data
            //else if data.stationary && self.runInProgress {
            else if data.confidence == .High && !data.running && self.runInProgress {
                self.stopRun()
            }
        }
    }
    
    func startRun() {
        
        print("Starting a run")
        self.runInProgress = true
        locationManager.startCapture()
        
        // Prep for a new route
        route = []
        startDate = NSDate()
    }
    
    func stopRun() {
        
        print("Stopping a run")
        self.runInProgress = false
        locationManager.stopCapture()
        
        // Create the workout
        let run = HKWorkout(
            activityType: .Running,
            startDate: self.startDate!,
            endDate: self.endDate ?? NSDate(),
            duration: (self.endDate?.timeIntervalSinceDate(self.startDate!))!,
            totalEnergyBurned: nil,
            totalDistance: self.distance,
            device: HKDevice.localDevice(),
            metadata: nil
        )
        
        // Get a reference to the HKHealthStore instance
        guard let store = HealthManager.singleton?.healthStore else {
            return
        }
        
        // Save the workout
        store.saveObject(run) {
            success, error in
            guard success else {
                // Perform proper error handling here
                fatalError("*** An error occurred while saving the run: \(error?.localizedDescription)")
            }
            
            // If we want, we can add samples for discrete intervals within the workout here...
        }
        
        // Persist the raw GPS data
        self.saveData()
    }
    
    func addPointsToRoute(locations: [CLLocation]) {

        // Make sure a run is in progress
        guard self.runInProgress else {
            return
        }

        // Add points to the array
        route.appendContentsOf(locations)

        // Recalculate distance
        
        // Fix the end of the interval to search
        self.endDate = NSDate()
        
        // Get a reference to the HKHealthStore instance
        guard let store = HealthManager.singleton?.healthStore else {
            return
        }
        
        // Restrict samples to distance
        guard let sampleType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning) else {
            fatalError("*** This method should never fail")
        }
        
        // Find samples within the given interval
        let predicate = HKQuery.predicateForSamplesWithStartDate(startDate!, endDate: endDate, options: .StrictStartDate)
        
        // Query the store
        let query = HKStatisticsQuery(quantityType: sampleType, quantitySamplePredicate: predicate, options: .CumulativeSum) {
            query, result, error in

            // Add distance traversed since the last check-in
            if let result = result {
                self.distance = result.sumQuantity()
            }
        }
        
        // Run the query
        store.executeQuery(query)
    }
    
    // Prepare data for submission
    func saveData() {
        let params = self.route.map({
            (location: CLLocation) -> Dictionary<String, String> in
            return [
                "latitude": String(location.coordinate.latitude),
                "longitude": String(location.coordinate.longitude),
                "accuracy": String(location.horizontalAccuracy),
                "timestamp": location.timestamp.descriptionWithLocale(nil),
                "speed": String(location.speed)
            ]
        })
        
        FileManager.singleton.post(params)
    }
}
