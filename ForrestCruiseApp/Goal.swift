//
//  Goal.swift
//  ForrestCruiseApp
//
//  Created by Daniel Sauble on 8/17/16.
//  Copyright © 2016 Daniel Sauble. All rights reserved.
//

import Foundation

class Goal: NSObject, NSCoding {
    
    // MARK: Properties
    
    var milesPerWeek: Double = 0.0 {
        didSet {
            self.saveGoal()
        }
    }
    var pace: Double = 0.0 {
        didSet {
            self.saveGoal()
        }
    }
    
    // MARK: Types
    
    struct PropertyKey {
        static let milesPerWeekKey = "mpw"
        static let paceKey = "pace"
    }
    
    // MARK: Initialization
    
    override init() {
        super.init()
        
        self.loadGoal()
    }
    
    init(milesPerWeek: Double, pace: Double) {
        super.init()
        
        self.milesPerWeek = milesPerWeek
        self.pace = pace
    }
    
    // MARK: NSCoding
    
    func saveGoal() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(self, toFile: Goal.ArchiveURL.path!)
        if !isSuccessfulSave {
            print("Failed to save goal")
        }
    }
    
    func loadGoal() {
        if let goal = NSKeyedUnarchiver.unarchiveObjectWithFile(Goal.ArchiveURL.path!) as? Goal {
            self.milesPerWeek = goal.milesPerWeek
            self.pace = goal.pace
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeDouble(milesPerWeek, forKey: PropertyKey.milesPerWeekKey)
        aCoder.encodeDouble(pace, forKey: PropertyKey.paceKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let milesPerWeek = aDecoder.decodeDoubleForKey(PropertyKey.milesPerWeekKey)
        let pace = aDecoder.decodeDoubleForKey(PropertyKey.paceKey)
        
        self.init(milesPerWeek: milesPerWeek, pace: pace)
    }
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("goal")
}