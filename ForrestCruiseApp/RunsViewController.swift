//
//  RunsViewController.swift
//  ForrestCruiseApp
//
//  Created by Daniel Sauble on 8/18/16.
//  Copyright © 2016 Daniel Sauble. All rights reserved.
//

import UIKit

class RunsViewController: UITableViewController {
    
    // MARK: Files
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use the edit button item provided by the table view controller
        navigationItem.leftBarButtonItem = editButtonItem()
    }
    
    // MARK: Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FileManager.singleton.pending.files?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier
        let cellIdentifier = "RunsTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! RunsTableViewCell
        
        // Fetches the appropriate file for the data source layout
        let file = FileManager.singleton.pending.files?[indexPath.row] ?? "Unknown file name"
        
        cell.fileName.text = file
        
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            FileManager.singleton.deleteFile((FileManager.singleton.pending.files?[indexPath.row])!)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
}
