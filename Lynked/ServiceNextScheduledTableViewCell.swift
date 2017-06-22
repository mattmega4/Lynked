//
//  ServiceNextScheduledTableViewCell.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 6/21/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit

class ServiceNextScheduledTableViewCell: UITableViewCell {
    
    @IBOutlet weak var serviceScheduledLabel: UILabel!
    @IBOutlet weak var serviceScheduledDatePicker: UIDatePicker!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
