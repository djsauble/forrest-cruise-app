//
//  TrendControl.swift
//  ForrestCruiseApp
//
//  Created by Daniel Sauble on 8/16/16.
//  Copyright © 2016 Daniel Sauble. All rights reserved.
//

import UIKit

class TrendControl: UIView {

    // MARK: Properties
    
    var trend = [Double]() {
        didSet {
            addBars()
            setNeedsLayout()
        }
    }
    var trendViews = [UIView]()
    
    // MARK: Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        
        guard self.trend.count > 0 else {
            return
        }
        
        let spacing = 1
        let barWidth = CGFloat((Int(frame.size.width) / self.trend.count) - spacing)
        
        // Find the max bar height
        if let max = self.trend.maxElement() {
            for (index, bar) in trendViews.enumerate() {
                let barHeight = CGFloat(Double(frame.size.height) * self.trend[index] / max)
                let x = CGFloat(index) * (barWidth + CGFloat(spacing))
                let y = frame.size.height - barHeight
                let barFrame = CGRect(x: x, y: y, width: barWidth, height: barHeight)
                bar.frame = barFrame
            }
        }
    }
    
    func addBars() {
        // Remove the existing trend bars
        trendViews.forEach({
            (view: UIView) in
            view.removeFromSuperview()
        })
        trendViews = []
        
        // Add the new trend bars
        if let max = self.trend.maxElement() {
            for val in self.trend {
                let view = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 100 * val / max))
                
                view.backgroundColor = UIColor.redColor()
                
                self.trendViews += [view]
                self.addSubview(view)
            }
        }
    }
}
