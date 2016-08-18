//
//  Pending.swift
//  ForrestCruiseApp
//
//  Created by Daniel Sauble on 7/23/16.
//  Copyright © 2016 Daniel Sauble. All rights reserved.
//

import Foundation

class FileList {
    var files: [String]? // List of files to upload
    
    init() {
        self.files = NSKeyedUnarchiver.unarchiveObjectWithFile(FileList.ArchiveURL.path!) as? [String]
        if self.files == nil {
            self.files = []
        }
        print("Loaded \(self.files!.count) files...")
    }
    
    func saveFileList() {
        if let files = self.files {
            print("Saving \(files.count) files...")
            let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(files, toFile: FileList.ArchiveURL.path!)
            
            if !isSuccessfulSave {
                print("Failed to save file list")
            }
        }
    }
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("files")
}