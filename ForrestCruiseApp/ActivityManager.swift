//
//  ActivityManager.swift
//  ForrestCruiseApp
//
//  Created by Daniel Sauble on 8/17/16.
//  Copyright © 2016 Daniel Sauble. All rights reserved.
//

import CoreMotion

class ActivityManager {
    
    static var singleton: ActivityManager? = ActivityManager()
    
    var activityManager: CMMotionActivityManager
    var callback: ((CMMotionActivity) -> Void)?
    
    init?() {
        guard CMMotionActivityManager.isActivityAvailable() else {
            return nil
        }
        
        activityManager = CMMotionActivityManager()
        activityManager.startActivityUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: self.handleActivityUpdates)
    }
    
    func handleActivityUpdates(data: CMMotionActivity?) {
        if let cb = self.callback, activity = data {
            dispatch_async(dispatch_get_main_queue()) {
                cb(activity)
            }
        }
    }
}
