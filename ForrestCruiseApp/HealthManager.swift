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
    var trendCallback: ((weeks: [HKStatistics]?) -> Void)?
    var todayCallback: ((day: HKStatistics?) -> Void)?
    var workoutCallback: ((weeks: [WorkoutSum]?) -> Void)?
    
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
            
            // Subscribe to trend updates
            self.subscribeTrend()
            
            // Subscribe to workout updates
            self.subscribeWorkouts()
            
            // Subscribe to today updates
            self.subscribeDay()
        })
    }
    
    // Request authorization
    func authorizeHealthKit(completion: ((success: Bool, error: NSError?) -> Void)!) {
        // Set the types you want to write to HK Store
        let healthKitTypesToShare = Set<HKSampleType>([
            HKObjectType.workoutType()
        ])
        
        // Set the types you want to read from HK Store
        let healthKitTypesToRead = Set<HKObjectType>([
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)!
        ])
        
        // Request HealthKit authorization
        self.healthStore.requestAuthorizationToShareTypes(healthKitTypesToShare, readTypes: healthKitTypesToRead, completion: completion)
    }
    
    // Subscribe to day updates
    func subscribeDay() {
        
        let calendar = NSCalendar.currentCalendar()
        
        // Set the start date to today at midnight
        let anchorComponents = calendar.components([.Day, .Month, .Year], fromDate: NSDate())
        let startDate = calendar.dateFromComponents(anchorComponents)
        let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: nil, options: .None)
        
        guard let quantityType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning) else {
            fatalError("*** This method should never fail***")
        }
        
        // Long-running query for daily data
        let query = HKObserverQuery(sampleType: quantityType, predicate: predicate) {
            query, completionHandler, error in
            
            if let error = error {
                // Perform proper error handling here
                fatalError("\(error.localizedDescription)")
            }
            
            // Take whatever steps are necessary to update your app's data and UI
            // This may involve executing other queries
            if let callback = self.todayCallback {
                self.getTodayDistance(callback)
            }
        }
 
        self.healthStore.executeQuery(query)
    }
    
    // Subscribe to workout updates
    func subscribeWorkouts() {
        
        let calendar = NSCalendar.currentCalendar()
        
        // Set the anchor week to Sunday at 12:00 a.m.
        let anchorComponents = calendar.components([.Day, .Month, .Year, .Weekday], fromDate: NSDate())
        
        let offset = (7 + anchorComponents.weekday - 1) % 7
        anchorComponents.day -= offset
        anchorComponents.hour = 0
        
        guard let anchorDate = calendar.dateFromComponents(anchorComponents) else {
            fatalError("*** Unable to create a valid date from the given components ***")
        }
        
        let quantityType = HKObjectType.workoutType()
        
        // Set the start date to 51 weeks before the anchor week
        let startDate = calendar.dateByAddingUnit(.Day, value: -7 * 51, toDate: anchorDate, options: .MatchFirst)
        let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: nil, options: .None)
        
        // Long-running query for daily data
        let query = HKObserverQuery(sampleType: quantityType, predicate: predicate) {
            query, completionHandler, error in
            
            if let error = error {
                // Perform proper error handling here
                fatalError("\(error.localizedDescription)")
            }
            
            // Take whatever steps are necessary to update your app's data and UI
            // This may involve executing other queries
            if let callback = self.workoutCallback {
                self.getWorkoutDistances(callback)
            }
        }
        
        self.healthStore.executeQuery(query)
    }
    
    // Subscribe to trend updates
    func subscribeTrend() {
        
        let calendar = NSCalendar.currentCalendar()
        
        let interval = NSDateComponents()
        interval.day = 7
        
        // Set the anchor date to Sunday at 12:00 a.m.
        let anchorComponents = calendar.components([.Day, .Month, .Year, .Weekday], fromDate: NSDate())
        
        let offset = (7 + anchorComponents.weekday - 1) % 7
        anchorComponents.day -= offset
        anchorComponents.hour = 0
        
        guard let anchorDate = calendar.dateFromComponents(anchorComponents) else {
            fatalError("*** Unable to create a valid date from the given components ***")
        }
        
        guard let quantityType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning) else {
            fatalError("*** This method should never fail ***")
        }
        
        // Set the start date to 51 weeks before the anchor week
        let startDate = calendar.dateByAddingUnit(.Day, value: -7 * 51, toDate: anchorDate, options: .MatchFirst)
        let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: nil, options: .None)
        
        // Create a long-running query
        let query = HKStatisticsCollectionQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: .CumulativeSum, anchorDate: anchorDate, intervalComponents: interval)
        
        // Set the results handlers
        query.initialResultsHandler = {
            query, collection, error in
            
            if let collection = collection, callback = self.trendCallback {
                dispatch_async(dispatch_get_main_queue()) {
                    callback(weeks: collection.statistics())
                }
            }
        }
        query.statisticsUpdateHandler = {
            query, statistics, collection, error in
            
            if let collection = collection, callback = self.trendCallback {
                dispatch_async(dispatch_get_main_queue()) {
                    callback(weeks: collection.statistics())
                }
            }
        }
        
        // Run the query
        self.healthStore.executeQuery(query)
    }
    
    // Get the distance traversed in the given week
    func getTodayDistance(callback: (day: HKStatistics?) -> Void) {
        let calendar = NSCalendar.currentCalendar()
        
        // Now
        let now = NSDate()
        
        // Start of today
        let components = calendar.components([.Year, .Month, .Day], fromDate: now)
        let today = calendar.dateFromComponents(components)
        
        guard let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning) else {
            fatalError("*** This method should never fail ***")
        }
        
        let predicate = HKQuery.predicateForSamplesWithStartDate(today, endDate: nil, options: .None)
        
        // Set up the query
        let query = HKStatisticsQuery(quantityType: sampleType, quantitySamplePredicate: predicate, options: .CumulativeSum) {
            query, results, error in
            
            // Call the callback on the main thread
            dispatch_async(dispatch_get_main_queue()) {
                callback(day: results)
            }
        }
        
        // Run the query
        self.healthStore.executeQuery(query)
    }
    
    // Get the workout distances over the past year
    func getWorkoutDistances(callback: (weeks: [WorkoutSum]?) -> Void) {
        
        let calendar = NSCalendar.currentCalendar()
        
        // Set the anchor week to Sunday at 12:00 a.m.
        let anchorComponents = calendar.components([.Day, .Month, .Year, .Weekday], fromDate: NSDate())
        
        let offset = (7 + anchorComponents.weekday - 1) % 7
        anchorComponents.day -= offset
        anchorComponents.hour = 0
        
        guard let anchorDate = calendar.dateFromComponents(anchorComponents) else {
            fatalError("*** Unable to create a valid date from the given components ***")
        }
        
        let quantityType = HKObjectType.workoutType()
        
        // Set the start date to 51 weeks before the anchor week
        let startDate = calendar.dateByAddingUnit(.Day, value: -7 * 51, toDate: anchorDate, options: .MatchFirst)
        let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: nil, options: .None)
        
        // Set up the query
        let query = HKSampleQuery(sampleType: quantityType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) {
            query, results, error in
            
            guard let samples = results as? [HKWorkout] else {
                fatalError("An error occurred fetching the list of workouts")
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
    func aggregateIntoWeeks(samples: [HKWorkout]) -> [WorkoutSum] {
        
        // Get the first day of this week
        let calendar = NSCalendar.currentCalendar()
        let now = NSDate()
        let components = calendar.components([.Year, .Month, .Day], fromDate: now)
        let today = calendar.dateFromComponents(components)
        let day0 = calendar.dateByAddingUnit(.Day, value: -(calendar.component(.Weekday, fromDate: today!) - 1), toDate: today!, options: [])

        // Loop variables
        var current = day0
        var distanceSum = 0.0
        var durationSum = 0.0
        var averagePace = 0.0
        
        // Reverse the sample array so we process newest values first
        let input = samples.reverse()
        var output = [WorkoutSum]()
        
        for sample in input {
            
            // If the next sample is older than the current week, append the current sum to the output array
            if current!.compare(sample.startDate) == .OrderedDescending {
                averagePace = distanceSum > 0 ? durationSum / distanceSum : 0.0
                output.append(WorkoutSum(distance: distanceSum, pace: averagePace))
                distanceSum = 0.0
                durationSum = 0.0
                current = calendar.dateByAddingUnit(.Day, value: -7, toDate: current!, options: [])
                continue
            }
            
            // Add to the sum
            if(sample.workoutActivityType == .Running) {
                distanceSum += sample.totalDistance?.doubleValueForUnit(HKUnit.mileUnit()) ?? 0.0
                durationSum += sample.duration / 60.0
            }
        }
        
        // Add the final sample to the output array
        averagePace = distanceSum > 0 ? durationSum / distanceSum : 0.0
        output.append(WorkoutSum(distance: distanceSum, pace: averagePace))

        return output.reverse()
    }
}