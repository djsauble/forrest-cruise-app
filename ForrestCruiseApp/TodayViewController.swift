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
    @IBOutlet weak var stopLabel: UILabel!
    @IBOutlet weak var walkLabel: UILabel!
    @IBOutlet weak var runLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Refresh the values
        if let manager = HealthManager.singleton {
            manager.callback = self.displayValues
        }
        
        // Check for activity events
        if let manager = ActivityManager.singleton {
            manager.callback = self.displayActivity
            self.stopLabel.textColor = UIColor.lightGrayColor()
            self.walkLabel.textColor = UIColor.lightGrayColor()
            self.runLabel.textColor = UIColor.lightGrayColor()
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
    
    func displayActivity(data: CMMotionActivity) {
        if data.confidence == .High {
            print("\(data.stationary) \(data.walking) \(data.running)")
            self.stopLabel.textColor = data.stationary ? UIColor.blackColor() : UIColor.lightGrayColor()
            self.walkLabel.textColor = data.walking ? UIColor.blackColor() : UIColor.lightGrayColor()
            self.runLabel.textColor = data.running ? UIColor.blackColor() : UIColor.lightGrayColor()
        }
    }
}

