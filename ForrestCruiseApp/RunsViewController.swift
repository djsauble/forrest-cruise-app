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
    var files: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Listen for updates to the backing data store
        FileManager.singleton.pending.callback = self.updateTable
        self.files = FileManager.singleton.pending.getFiles()
    }
    
    func updateTable(files: [String]) {
        if !editing {
            self.files = files
            self.tableView?.reloadData()
        }
    }
    
    // MARK: Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier
        let cellIdentifier = "RunsTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! RunsTableViewCell
        
        // Fetches the appropriate file for the data source layout
        let file = files[indexPath.row]
        
        cell.runDayLabel.text = file
        
        return cell
    }
}
