//
//  GoalViewController.swift
//  ForrestCruiseApp
//
//  Created by Daniel Sauble on 8/17/16.
//  Copyright © 2016 Daniel Sauble. All rights reserved.
//

import UIKit

class GoalViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var goalDistancePicker: UIPickerView!
    @IBOutlet weak var goalPacePicker: UIPickerView!
    
    // MARK: Properties
    
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
    
    let goalMinPace = 4.0
    let goalMaxPace = 15.0
    
    var goal = Goal()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.goalDistancePicker.delegate = self
        self.goalDistancePicker.dataSource = self
        self.goalDistancePicker.selectRow(rowFromDistance(goal.milesPerWeek), inComponent: 0, animated: false)
        
        self.goalPacePicker.delegate = self
        self.goalPacePicker.dataSource = self
        self.goalPacePicker.selectRow(rowFromPace(goal.pace), inComponent: 0, animated: false)
    }
    
    func rowFromDistance(distance: Double) -> Int {
        var current = 10.0
        var i = 0
        
        while (current < distance && i < goalDistances.count - 1) {
            current += 10
            i += 1
        }
        
        return i
    }
    
    func rowFromPace(pace: Double) -> Int {
        var current = self.goalMinPace
        var i = 0
        
        while current < pace && current < self.goalMaxPace {
            current += 0.5
            i += 1
        }
        
        return i
    }
    
    // MARK: UIPickerViewDelegate
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView === self.goalDistancePicker {
            return self.goalDistances.count
        }
        else {
            return Int(self.goalMaxPace - self.goalMinPace) * 2
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView === self.goalDistancePicker {
            return String(self.goalDistances[row]["race"]!)
        }
        else {
            let minute = row / 2
            let halfMinute = (row % 2 == true)
            return "\(Int(self.goalMinPace + Double(minute))):\(halfMinute ? "30" : "00")"
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView === self.goalDistancePicker {
            self.goal.milesPerWeek = goalDistances[row]["mpw"] as! Double
        }
        else {
            let minute = row / 2
            let halfMinute = (row % 2 == true)
            self.goal.pace = self.goalMinPace + Double(minute) + (halfMinute ? 0.5 : 0.0)
        }
    }
}
