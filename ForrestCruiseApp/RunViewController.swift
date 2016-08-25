//
//  RunViewController.swift
//  ForrestCruiseApp
//
//  Created by Daniel Sauble on 8/25/16.
//  Copyright © 2016 Daniel Sauble. All rights reserved.
//

import UIKit
import CoreLocation
import HealthKit

class RunViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    var locationManager = LocationManager()
    var route: [CLLocation] = []
    var startDate: NSDate?
    var endDate: NSDate?
    var distance: HKQuantity?
    var runInProgress: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Start polling for location
        locationManager.callback = self.addPointsToRoute
        
        // Start the run
        if !self.runInProgress {
            resetRun()
            startRun()
        }
    }
    
    @IBAction func endRun(sender: AnyObject) {
        stopRun()
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func resetRun() {
        
        print("Resetting a run")
        runInProgress = false
        startDate = nil
        endDate = nil
        distance = nil
        route = []
        locationManager.stopCapture()
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
            duration: self.endDate?.timeIntervalSinceDate(self.startDate!) ?? NSTimeInterval(0),
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
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.distanceLabel.text = "\(round(self.distance?.doubleValueForUnit(HKUnit.mileUnit()) ?? 0.0 * 10.0) / 10.0) miles"
                }
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