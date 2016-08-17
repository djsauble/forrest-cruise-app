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
    var callback: ((weeks: [Double]?) -> Void)?
    
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
                self.getWeeklyDistance(26, callback: cb)
            }
        }
        
        // Run the query
        self.healthStore.executeQuery(query)
    }
    
    // Get the distance traversed in the given week
    func getWeeklyDistance(weeks: Int = 2, callback: (weeks: [Double]?) -> Void) {
        let calendar = NSCalendar.currentCalendar()
        
        // Now
        let now = NSDate()
        
        // Start of today
        let components = calendar.components([.Year, .Month, .Day], fromDate: now)
        let today = calendar.dateFromComponents(components)
        
        // Start of the week
        let day0 = calendar.dateByAddingUnit(.Day, value: -(calendar.component(.Weekday, fromDate: today!) - 1), toDate: today!, options: [])
        
        // Start of the time period (inclusive)
        let start = calendar.dateByAddingUnit(.Day, value: -((weeks - 1) * 7), toDate: day0!, options: [])
        
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
            
            let weeks = self.aggregateIntoWeeks(samples)
            
            // Call the callback on the main thread
            dispatch_async(dispatch_get_main_queue()) {
                callback(weeks: weeks)
            }
        }
        
        // Run the query
        self.healthStore.executeQuery(query)
    }
    
    // Aggregate sample data by weeks
    func aggregateIntoWeeks(samples: [HKQuantitySample]) -> [Double] {
        
        // Get the first day of this week
        let calendar = NSCalendar.currentCalendar()
        let now = NSDate()
        let components = calendar.components([.Year, .Month, .Day], fromDate: now)
        let today = calendar.dateFromComponents(components)
        let day0 = calendar.dateByAddingUnit(.Day, value: -(calendar.component(.Weekday, fromDate: today!) - 1), toDate: today!, options: [])
        
        // Loop variables
        var current = day0
        var sum = 0.0
        
        // Reverse the sample array so we process newest values first
        let input = samples.reverse()
        var output = [Double]()
        
        for sample in input {
            
            // If the next sample is older than the current week, append the current sum to the output array
            if current!.compare(sample.startDate) == .OrderedDescending {
                output.append(sum)
                sum = 0
                current = calendar.dateByAddingUnit(.Day, value: -7, toDate: current!, options: [])
                continue
            }
            
            // Add to the sum
            sum += sample.quantity.doubleValueForUnit(HKUnit.mileUnit())
        }
        
        // Add the final sample to the output array
        output.append(sum)
        
        return output
    }
}