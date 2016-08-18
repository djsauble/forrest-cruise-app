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
    }
    
    // MARK: Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = FileManager.singleton.pending.files?.count ?? 0
        print(count)
        return count
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
}
