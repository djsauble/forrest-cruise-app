//
//  RunViewController.swift
//  ForrestCruiseApp
//
//  Created by Daniel Sauble on 8/18/16.
//  Copyright © 2016 Daniel Sauble. All rights reserved.
//

import UIKit
import HealthKit
import CoreLocation

class RunViewController: UIViewController {
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    // MARK: Properties
    
    var route: NSMutableArray = NSMutableArray()
    var startDate: NSDate?
    var endDate: NSDate?
    var distance: HKQuantity?
    
    struct MetadataKey {
        static let gps = "GPS_TRACE"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Run started")
        
        // Prep for a new route
        route = NSMutableArray()
        startDate = NSDate()
        endDate = startDate
        LocationManager.singleton.callback = self.addPointsToRoute
        
        // Start capturing location data
        LocationManager.singleton.startCapture()
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        print("Run stopped")
        
        // Stop capturing location data
        LocationManager.singleton.stopCapture()

        // Create the workout
        let run = HKWorkout(
                    activityType: .Running,
                    startDate: startDate!,
                    endDate: endDate!,
                    duration: (endDate?.timeIntervalSinceDate(startDate!))!,
                    totalEnergyBurned: nil,
                    totalDistance: distance,
                    device: HKDevice.localDevice(),
                    // TODO: Figure out how to attach GPS data to a workout
                    //metadata: [
                    //    MetadataKey.gps: route
                    //]
                    metadata: nil
                  )
        
        // Get the HKHealthStore instance
        guard let store = HealthManager.singleton?.healthStore else {
            fatalError("Could not access the shared HKHealthStore instance")
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
    }
    
    func addPointsToRoute(locations: [CLLocation]) {
        route.addObjectsFromArray(locations)
        
        // Fix the end of the interval to search
        let now = NSDate()
        
        // Get a reference to the HKHealthStore instance
        guard let store = HealthManager.singleton?.healthStore else {
            return
        }
        
        // Restrict samples to distance
        guard let sampleType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning) else {
            fatalError("*** This method should never fail")
        }
        
        // Find samples within the given interval
        let predicate = HKQuery.predicateForSamplesWithStartDate(endDate!, endDate: now, options: .StrictStartDate)
        
        // Query the store
        let query = HKStatisticsQuery(quantityType: sampleType, quantitySamplePredicate: predicate, options: .CumulativeSum) {
            query, result, error in
            
            // Initialize distance to zero if nil
            if self.distance == nil {
                self.distance = HKQuantity(unit: HKUnit.mileUnit(), doubleValue: 0)
            }
            let current = self.distance!.doubleValueForUnit(HKUnit.mileUnit())
            
            // Add distance traversed since the last check-in
            if let result = result {
                
                // Fetch the new distance
                let sum = result.sumQuantity()?.doubleValueForUnit(HKUnit.mileUnit()) ?? 0.0
                
                self.distance = HKQuantity(unit: HKUnit.mileUnit(), doubleValue: current + sum)
            }
            
            // Update the display on the main thread
            dispatch_async(dispatch_get_main_queue()) {
                self.displayDistance()
            }
        }
        
        // Run the query
        store.executeQuery(query)
        
        // Update the end date
        endDate = now
    }
    
    // Show the current distance in the UI
    func displayDistance() {
        self.distanceLabel.text = "\(self.distance!.doubleValueForUnit(HKUnit.mileUnit())) miles"
    }
}
