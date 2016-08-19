//
//  URLManager.swift
//  ForrestCruiseApp
//
//  Created by Daniel Sauble on 2/29/16.
//  Copyright © 2016 Daniel Sauble. All rights reserved.
//

import Foundation

class RemoteAPI {
    
    // MARK: Properties
    
    // Production
    static var ws = "wss://api-generator2.herokuapp.com/api"
    static var base = "https://api-generator2.herokuapp.com/api/runs"
    
    // Local
    //static var ws = "ws://127.0.0.1:5000/ws"
    //static var base = "http://127.0.0.1:5000/api/runs"

    // Credentials
    var user: String?
    var token: String?
    
    init() {
        // Read the user ID
        if let u = NSKeyedUnarchiver.unarchiveObjectWithFile(RemoteAPI.UserArchiveURL.path!) {
            self.user = u as? String
        }
        else {
            self.user = nil
        }
        
        // Read the user token
        if let t = NSKeyedUnarchiver.unarchiveObjectWithFile(RemoteAPI.TokenArchiveURL.path!) {
            self.token = t as? String
        }
        else {
            self.token = nil
        }
    }
    
    func reset() {
        self.user = ""
        self.token = ""
        save()
    }
    
    func save() {
        // Save the user ID
        if let u = self.user {
            let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(u, toFile: RemoteAPI.UserArchiveURL.path!)
            
            if !isSuccessfulSave {
                print("Failed to save user ID")
            }
        }
        
        // Save the user token
        if let t = self.token {
            let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(t, toFile: RemoteAPI.TokenArchiveURL.path!)
            
            if !isSuccessfulSave {
                print("Failed to save user token")
            }
        }
    }
    
    // Compose the run submission URL based on the stored credentials
    func url() -> NSURL? {
        if let u = self.user {
            if let t = self.token {
                if !u.isEmpty && !t.isEmpty {
                    return NSURL(string: "\(RemoteAPI.base)?user=\(u)&token=\(t)");
                }
            }
        }
        return nil
    }
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let UserArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("user")
    static let TokenArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("token")
}