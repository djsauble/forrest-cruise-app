//
//  FileManager.swift
//  ForrestCruiseApp
//
//  Created by Daniel Sauble on 3/4/16.
//  Copyright © 2016 Daniel Sauble. All rights reserved.
//

import Foundation

class FileManager: NSObject, NSURLSessionDelegate, NSURLSessionDataDelegate {
    
    static var singleton = FileManager()
    
    var task: NSURLSessionUploadTask?
    var session: NSURLSession?
    var id = "runcapture"
    var savedCompletionHandler: (() -> Void)?
    var responsesData: [Int:NSMutableData] = [:]
    var responseData: NSMutableData? = nil
    var pending = FileList()
    
    override init() {
        self.session = nil
        self.savedCompletionHandler = nil
        
        super.init()
        
        // Configure the URL session
        let config = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(id)
        self.session = NSURLSession(configuration: config, delegate: self, delegateQueue: nil)
    }
    
    // Submit data to the web service
    func post(params: [Dictionary<String, String>]) {

        // Serialize the JSON and write it to a file
        var path: String? = nil
        do {
            let options = NSJSONWritingOptions()
            let data = try NSJSONSerialization.dataWithJSONObject(params, options: options)

            // Create a file for upload
            let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
            let docs: NSString = paths[0] as NSString
            let filename = "\(NSUUID().UUIDString).json"
            path = docs.stringByAppendingPathComponent(filename)
            let test = data.writeToFile(path!, atomically: true)
            if test {
                print("File written to disk successfully!")
                
                // Add the file to the upload queue
                self.queue(filename)
            }
            else {
                print("File write FAILED")
            }
        }
        catch {
            print("Error serializing params!")
        }
    }
    
    // Kick the queue (start an upload if none in progress)
    func kick() {
        // Any uploads in progress?
        if self.task == nil || self.task!.state == NSURLSessionTaskState.Completed {
            // Any runs in the queue?
            if let files = self.pending.files {
                if files.count > 0 {
                    self.upload(self.pending.files!.first!)
                }
            }
        }
    }
    
    // Queue a file for upload
    func queue(file: String) {
        if self.pending.files != nil {
            self.pending.files!.append(file)
            self.pending.saveFileList()
            self.kick()
        }
    }
    
    // Upload a file that is stored on disk
    func upload(file: String) {
        if let url = URL.singleton.url() {
            // Configure HTTP request
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "PUT"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // Start the upload
            let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
            let docs: NSString = paths[0] as NSString
            let path = docs.stringByAppendingPathComponent(file)
            self.task = self.session?.uploadTaskWithRequest(request, fromFile: NSURL(fileURLWithPath: path));
            if let t = task {
                t.resume();
            }
        }
        else {
            print("No URL specified. Cannot upload.")
        }
    }
    
    // NSURLSessionDelegate
    
    func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
        print("Session invalidated!");
    }
    
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if let err = error {
            print("Error!")
            print(err)
        }
        else {
            print("All done")
        }
        
        self.responseData = self.responsesData[task.taskIdentifier]
        
        if let r = self.responseData {
            if let str = NSString(data: r, encoding: NSUTF8StringEncoding) {
                if str.length == 0 {
                    if self.pending.files != nil {
                        // Delete the file that has been uploaded successfully
                        do {
                            let file = self.pending.files!.removeFirst()
                            self.pending.saveFileList()
                            let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
                            let docs: NSString = paths[0] as NSString
                            let path = docs.stringByAppendingPathComponent(file)
                            try NSFileManager.defaultManager().removeItemAtPath(path)
                        } catch _ {
                            print("Was unable to delete the old file")
                        }
                        
                        // See if there are more files to upload
                        if self.pending.files!.count > 0 {
                            print("Starting the next upload...")
                            self.upload(self.pending.files!.first!)
                        }
                    }
                }
                else {
                    print(str)
                }
            }
            
        }
        else {
            print("Response is nil")
        }
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        print("Received data!")
        self.responseData = self.responsesData[dataTask.taskIdentifier]
        if self.responseData != nil {
            self.responseData!.appendData(data)
        }
        else {
            self.responseData = NSMutableData(data: data)
            self.responsesData[dataTask.taskIdentifier] = self.responseData!
        }
    }
    
    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        completionHandler(
            NSURLSessionAuthChallengeDisposition.UseCredential,
            NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!)
        )
    }
    
    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        print("All enqueued messages delivered");
        
        if let handler = self.savedCompletionHandler {
            handler()
            self.savedCompletionHandler = nil
        }
    }
}