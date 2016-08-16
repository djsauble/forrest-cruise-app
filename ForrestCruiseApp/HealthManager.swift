//
//  HealthManager.swift
//  ForrestCruiseApp
//
//  Created by Daniel Sauble on 8/15/16.
//  Copyright © 2016 Daniel Sauble. All rights reserved.
//

import HealthKit

class HealthManager {
    
    static var singleton: HealthManager? = HealthManager()
    
    var healthStore: HKHealthStore
    var callback: ((lastWeek: Double?, thisWeek: Double?) -> Void)?
    
    init?() {
        // App requires HealthKit
        if !HKHealthStore.isHealthDataAvailable() {
            return nil
        }
        
        // Get a reference to the store
        self.healthStore = HKHealthStore()
        
        // Request authorization
        authorizeHealthKit({
            (success: Bool, error: NSError?) -> Void in
            
            // Check the results
            if !success {
                fatalError("\(error?.localizedDescription)")
            }
            
            // Subscribe to updates
            self.subscribe()
        })
    }
    
    // Request authorization
    func authorizeHealthKit(completion: ((success: Bool, error: NSError?) -> Void)!) {
        // Set the types you want to read from HK Store
        let healthKitTypesToRead = Set<HKObjectType>([
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)!
        ])
        
        // Request HealthKit authorization
        self.healthStore.requestAuthorizationToShareTypes(nil, readTypes: healthKitTypesToRead, completion: completion)
    }
    
    // Subscribe for walk/run updates
    func subscribe() {
        guard let sampleType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning) else {
            fatalError("*** This method should never fail ***")
        }
        
        // Long-running query
        let query = HKObserverQuery(sampleType: sampleType, predicate: nil) {
            query, completionHandler, error in
            
            if let error = error {
                // Perform proper error handling here
                fatalError("\(error.localizedDescription)")
            }
            
            // Take whatever steps are necessary to update your app's data and UI
            // This may involve executing other queries
            if let cb = self.callback {
                self.getWeeklyDistance(cb)
            }
        }
        
        // Run the query
        self.healthStore.executeQuery(query)
    }
    
    // Get the distance traversed in the given week
    func getWeeklyDistance(callback: (lastWeek: Double?, thisWeek: Double?) -> Void) {
        let calendar = NSCalendar.currentCalendar()
        
        // Now
        let now = NSDate()
        
        // Start of today
        let components = calendar.components([.Year, .Month, .Day], fromDate: now)
        let today = calendar.dateFromComponents(components)
        
        // Start of the week
        let day0 = calendar.dateByAddingUnit(.Day, value: -(calendar.component(.Weekday, fromDate: today!) - 1), toDate: today!, options: [])
        
        // Start of the time period (inclusive)
        let start = calendar.dateByAddingUnit(.Day, value: -7, toDate: day0!, options: [])
        
        // End of the time period (exclusive)
        let end = now
        
        guard let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning) else {
            fatalError("*** This method should never fail ***")
        }
        
        let predicate = HKQuery.predicateForSamplesWithStartDate(start, endDate: end, options: .None)
        
        // Set up the query
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) {
            query, results, error in
            
            guard let samples = results as? [HKQuantitySample] else {
                fatalError("\(error?.localizedDescription)")
            }
            
            var lastWeek = 0.0
            var thisWeek = 0.0
            for sample in samples {
                if day0!.compare(sample.startDate) == .OrderedDescending {
                    lastWeek += sample.quantity.doubleValueForUnit(HKUnit.mileUnit())
                }
                else {
                    thisWeek += sample.quantity.doubleValueForUnit(HKUnit.mileUnit())
                }
            }
            
            callback(lastWeek: lastWeek, thisWeek: thisWeek)
        }
        
        // Run the query
        self.healthStore.executeQuery(query)
    }
}