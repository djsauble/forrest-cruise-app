//
//  GoalViewController.swift
//  ForrestCruiseApp
//
//  Created by Daniel Sauble on 8/15/16.
//  Copyright © 2016 Daniel Sauble. All rights reserved.
//

import UIKit

class GoalViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Refresh the values
        if let manager = HealthManager.singleton {
            manager.callback = self.displayValues
        }
    }

    func displayValues(lastWeek: Double?, thisWeek: Double?) {
        print("\(lastWeek) miles last week, \(thisWeek) miles this week")
    }
}

