//
//  TodayViewController.swift
//  ForrestCruiseApp
//
//  Created by Daniel Sauble on 8/15/16.
//  Copyright © 2016 Daniel Sauble. All rights reserved.
//

import UIKit
import CoreMotion

class TodayViewController: UIViewController {
    
    @IBOutlet weak var trendView: TrendControl!
    @IBOutlet weak var weeklyGoalView: WeeklyGoalControl!
    
    // MARK: Properties
    
    var runInProgress: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Refresh the values
        if let manager = HealthManager.singleton {
            manager.callback = self.displayValues
        }
        
        // Check for activity events
        if let manager = ActivityManager.singleton {
            manager.callback = self.onActivityChange
        }
    }

    func displayValues(weeks: [Double]?, day: Double) {
        
        // Sanity checks
        guard let data = weeks else {
            // No data
            return
        }
        guard data.count >= 2 else {
            // Not enough data
            return
        }
        
        // Display
        weeklyGoalView.weeklyGoal = data[1] * 1.1
        weeklyGoalView.thisWeek = data[0]
        weeklyGoalView.today = day
        trendView.trend = data.reverse()
    }
    
    func onActivityChange(data: CMMotionActivity) {
        // Start recording GPS data
        //if data.confidence == .High && data.running && !self.runInProgress {
        if data.stationary && !self.runInProgress {
            self.performSegueWithIdentifier("recordRun", sender: self)
            self.runInProgress = true
        }
        // Stop recording GPS data
        else if data.stationary && self.runInProgress {
            self.dismissViewControllerAnimated(true, completion: nil)
            self.runInProgress = false
        }
    }
}

