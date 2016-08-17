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
    
    let goalMinPace = 4
    let goalMaxPace = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.goalDistancePicker.delegate = self
        self.goalDistancePicker.dataSource = self
        
        self.goalPacePicker.delegate = self
        self.goalPacePicker.dataSource = self
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
            return (self.goalMaxPace - self.goalMinPace) * 2
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView === self.goalDistancePicker {
            return String(self.goalDistances[row]["race"]!)
        }
        else {
            let minute = row / 2
            let halfMinute = (row % 2 == true)
            return "\(self.goalMinPace + minute):\(halfMinute ? "30" : "00")"
        }
    }
}
