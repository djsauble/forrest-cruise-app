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
    
    // MARK: Properties
    
    @IBOutlet weak var paceView: PaceControl!
    @IBOutlet weak var trendView: TrendControl!
    @IBOutlet weak var weeklyGoalView: WeeklyGoalControl!
    
    let goalDistances = [
        [ "mpw": 10, "race": "5k" ],
        [ "mpw": 20, "race": "10k" ],
        [ "mpw": 30, "race": "Half marathon" ],
        [ "mpw": 40, "race": "Marathon" ],
        [ "mpw": 50, "race": "50k ultra" ],
        [ "mpw": 60, "race": "50 mile ultra" ],
        [ "mpw": 70, "race": "100k ultra" ],
        [ "mpw": 80, "race": "100 mile ultra" ]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Refresh the values
        if let manager = HealthManager.singleton {
            manager.workoutCallback = self.displayWorkouts
            manager.trendCallback = self.displayTrend
            manager.todayCallback = self.displayDay
        }
    }
    
    func displayWorkouts(weeks: [WorkoutSum]?) {
        if let data = weeks {
            self.trendView.workoutTrend = data.map({
                p in
                return p.distance
            })
            self.paceView.trend = data.map({
                p in
                return p.pace
            })
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
}

