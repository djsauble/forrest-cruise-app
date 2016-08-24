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
    
    @IBOutlet weak var trendView: TrendControl!
    @IBOutlet weak var weeklyGoalView: WeeklyGoalControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Refresh the values
        if let manager = HealthManager.singleton {
            manager.workoutCallback = self.displayWorkouts
            manager.trendCallback = self.displayTrend
            manager.todayCallback = self.displayDay
        }
    }
    
    func displayWorkouts(weeks: [Double]?) {
        if let data = weeks {
            self.trendView.workoutTrend = data
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

