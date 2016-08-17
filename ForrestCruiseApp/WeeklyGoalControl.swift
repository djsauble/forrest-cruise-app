//
//  WeeklyGoalControl.swift
//  ForrestCruiseApp
//
//  Created by Daniel Sauble on 8/16/16.
//  Copyright © 2016 Daniel Sauble. All rights reserved.
//

import UIKit

class WeeklyGoalControl: UIView {
    
    // MARK: Properties
    
    var weeklyGoal: Double = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    var thisWeek: Double = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    var today: Double = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var weeklyGoalLabel = UILabel()
    
    var thisWeekLabel = UILabel()
    var thisWeekBar = UIView()
    
    var thisDayLabel = UILabel()
    var thisDayBar = UIView()
    
    var remainingBar = UIView()
    
    // MARK: Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.addSubview(weeklyGoalLabel)
        
        self.addSubview(thisWeekLabel)
        self.addSubview(thisWeekBar)
        
        self.addSubview(thisDayLabel)
        self.addSubview(thisDayBar)
        
        self.addSubview(remainingBar)
    }
    
    override func layoutSubviews() {
        
        guard self.weeklyGoal > 0 else {
            return
        }
        
        // Constants
        let barWidth = CGFloat(100)
        let textSpacing = CGFloat(10)
        let textHeight = CGFloat(20)
        
        // Calculations
        let remaining = self.weeklyGoal - self.thisWeek
        let calendar = NSCalendar.currentCalendar()
        let now = NSDate()
        let daysLeft = 7 - calendar.component(.Weekday, fromDate: now)
        let thisDay = (remaining / Double(daysLeft)) - self.today
        let nextDays = remaining - thisDay
        
        // Bars
        thisWeekBar.backgroundColor = UIColor.redColor()
        let thisWeekHeight = frame.size.height * CGFloat(self.thisWeek / self.weeklyGoal)
        thisWeekBar.frame = CGRect(x: CGFloat(0), y: frame.size.height - thisWeekHeight, width: barWidth, height: thisWeekHeight)
        
        thisDayBar.backgroundColor = UIColor.yellowColor()
        let thisDayHeight = frame.size.height * CGFloat(thisDay / self.weeklyGoal)
        thisDayBar.frame = CGRect(x: CGFloat(0), y: frame.size.height - thisWeekHeight - thisDayHeight, width: barWidth, height: thisDayHeight)
        
        remainingBar.backgroundColor = UIColor.lightGrayColor()
        let remainingHeight = frame.size.height * CGFloat(nextDays / self.weeklyGoal)
        remainingBar.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: barWidth, height: remainingHeight)
        
        // Labels
        weeklyGoalLabel.text = "\(round(self.weeklyGoal * 10) / 10) miles this week"
        weeklyGoalLabel.frame = CGRect(x: barWidth + textSpacing, y: 0, width: frame.size.width - barWidth - textSpacing, height: textHeight)

        thisDayLabel.text = "\(round(thisDay * 10) / 10) miles left today"
        thisDayLabel.frame = CGRect(x: barWidth + textSpacing, y: frame.size.height - thisWeekHeight - thisDayHeight, width: frame.size.width - barWidth - textSpacing, height: textHeight)

        thisWeekLabel.text = "\(round(self.thisWeek * 10) / 10) miles so far"
        thisWeekLabel.frame = CGRect(x: barWidth + textSpacing, y: frame.size.height - thisWeekHeight, width: frame.size.width - barWidth - textSpacing, height: textHeight)
    }
}
