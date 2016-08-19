//
//  TodayViewController.swift
//  ForrestCruiseApp
//
//  Created by Daniel Sauble on 8/15/16.
//  Copyright © 2016 Daniel Sauble. All rights reserved.
//

import UIKit
import CoreMotion
import HealthKit

class TodayViewController: UIViewController {
    
    @IBOutlet weak var trendView: TrendControl!
    @IBOutlet weak var weeklyGoalView: WeeklyGoalControl!
    
    // MARK: Properties
    
    var runInProgress: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Refresh the values
        if let manager = HealthManager.singleton {
            manager.trendCallback = self.displayTrend
            manager.todayCallback = self.displayDay
        }
        
        // Check for activity events
        if let manager = ActivityManager.singleton {
            manager.callback = self.onActivityChange
        }
    }
    
    func displayTrend(weeks: [HKStatistics]?) {
        if let weeks = weeks {
            var data = weeks.map({
                week in
                return week.sumQuantity()?.doubleValueForUnit(HKUnit.mileUnit()) ?? 0.0
            })
            
            if data.count > 1 {
                self.weeklyGoalView.weeklyGoal = data[data.count - 2] * 1.1
            }
            if data.count > 0 {
                self.weeklyGoalView.thisWeek = data.last!
            }
            self.trendView.trend = data
        }
    }

    func displayDay(day: HKStatistics?) {
        if let day = day {
            self.weeklyGoalView.today = day.sumQuantity()?.doubleValueForUnit(HKUnit.mileUnit()) ?? 0.0
        }
    }
    
    func onActivityChange(data: CMMotionActivity) {
        // Start recording GPS data
        if data.confidence == .High && data.running && !self.runInProgress {
        //if data.stationary && !self.runInProgress {
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

