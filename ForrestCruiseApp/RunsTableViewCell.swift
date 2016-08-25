//
//  RunsTableViewCell.swift
//  ForrestCruiseApp
//
//  Created by Daniel Sauble on 8/18/16.
//  Copyright © 2016 Daniel Sauble. All rights reserved.
//

import UIKit

class RunsTableViewCell: UITableViewCell {
    
    // MARK: Properties
    @IBOutlet weak var runDayLabel: UILabel!
    @IBOutlet weak var runDataLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for this selected state
    }
}
