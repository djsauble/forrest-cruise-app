//
//  Pending.swift
//  ForrestCruiseApp
//
//  Created by Daniel Sauble on 7/23/16.
//  Copyright © 2016 Daniel Sauble. All rights reserved.
//

import Foundation
import SwiftWebSocket

class FileList {
    var pending: [String]? // List of files to upload
    var uploaded: [String] = [] // List of files that exist on the server
    var remote: RemoteAPI
    var callback: ((files: [String]) -> Void)?
    
    init(remote: RemoteAPI) {
        self.remote = remote
        
        loadFileList()
        getUploadedFiles()
    }
    
    func getUploadedFiles() {
        let ws = WebSocket()
        ws.event.open = {
            ws.send("{\"type\": \"run:list\", \"data\": {\"user\": \"\(self.remote.user!)\", \"token\": \"\(self.remote.token!)\"} }")
        }
        ws.event.message = { message in
            let data = String(message).dataUsingEncoding(NSUTF8StringEncoding)
            do {
                // Deserialize the JSON response
                let object = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                let type = object["type"] as! String
                if type == "run:list" {
                    let runs = object["data"] as! NSArray
                    for run in runs {
                        self.uploaded.append(run["timestamp"] as! String)
                    }
                }
                print("Loaded \(self.uploaded.count) files from server")
                
                // Send update to the callback
                if let callback = self.callback {
                    callback(files: self.getFiles())
                }
            }
            catch {
                // Recover
            }
            ws.close()
        }
        if (RemoteAPI.ws.hasPrefix("wss")) {
            ws.allowSelfSignedSSL = true
        }
        ws.open(RemoteAPI.ws)
    }
    
    func loadFileList() {
        self.pending = NSKeyedUnarchiver.unarchiveObjectWithFile(FileList.ArchiveURL.path!) as? [String]
        if self.pending == nil {
            self.pending = []
        }
        print("Loaded \(self.pending!.count) files from disk...")
        
        // Send update to the callback
        if let callback = self.callback {
            callback(files: self.getFiles())
        }
    }
    
    func saveFileList() {
        if let files = self.pending {
            print("Saving \(files.count) files...")
            let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(files, toFile: FileList.ArchiveURL.path!)
            
            if !isSuccessfulSave {
                print("Failed to save file list")
            }
        }
    }
    
    // MARK: Public API
    
    func getPendingFiles() -> [String] {
        if let pending = self.pending {
            return pending.reverse()
        }
        return []
    }
    
    func getFiles() -> [String] {
        var files = [String]()
        files.appendContentsOf(self.uploaded)
        
        if let pending = self.pending {
            files.appendContentsOf(pending)
        }
        
        return files.reverse()
    }
    
    func getNextUpload() -> String? {
        if let files = self.pending {
            return files.first
        }
        return nil
    }
    
    func addUpload(file: String) {
        self.pending?.insert(file, atIndex: 0)
        self.saveFileList()
        
        // Send update to the callback
        if let callback = self.callback {
            callback(files: self.getFiles())
        }
    }
    
    func removeFile(file: String) {
        if let index = self.pending?.indexOf(file) {
            self.pending?.removeAtIndex(index)
        }
        self.saveFileList()
        
        // Send update to the callback
        if let callback = self.callback {
            callback(files: self.getFiles())
        }
    }
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("files")
}