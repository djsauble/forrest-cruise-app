//
//  PaceControl.swift
//  ForrestCruiseApp
//
//  Created by Daniel Sauble on 8/30/16.
//  Copyright © 2016 Daniel Sauble. All rights reserved.
//

import UIKit

class PaceControl: UIView {
    
    // MARK: Properties
    
    let maxWeeks = 52
    
    var trend = [Double]() {
        didSet {
            // Pad with zeroes
            while trend.count < maxWeeks {
                trend.insert(0, atIndex: 0)
            }
            // Remove extra weeks
            while trend.count > maxWeeks {
                trend.removeAtIndex(0)
            }
            render()
        }
    }
    var trendViews = [UIView?]()
    
    // MARK: Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        
        guard self.trend.count > 0 else {
            return
        }
        
        let spacing = 1
        let barWidth = (frame.size.width / CGFloat(self.trend.count)) - CGFloat(spacing)
        
        // Find the max bar height
        if let max = self.trend.maxElement() {
            
            // Add trend bars
            for (index, bar) in trendViews.enumerate() {
                if bar == nil {
                    continue
                }
                let barHeight = CGFloat(Double(frame.size.height) * self.trend[index] / max)
                let x = CGFloat(index) * (barWidth + CGFloat(spacing))
                let y = frame.size.height - barHeight
                let barFrame = CGRect(x: x, y: y, width: barWidth, height: barHeight)
                bar!.frame = barFrame
            }
        }
    }
    
    func render() {
        // Remove the existing trend bars
        trendViews.forEach({
            (view: UIView?) in
            view?.removeFromSuperview()
        })
        trendViews = []
        
        if let max = self.trend.maxElement() {
            
            // Add the new trend bars
            for val in self.trend {
                let view: UIView? = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 100 * val / max))
                
                view!.backgroundColor = UIColor.greenColor()
                
                self.trendViews += [view]
                self.addSubview(view!)
            }
        }
        
        // Perform layout
        self.setNeedsLayout()
    }
}