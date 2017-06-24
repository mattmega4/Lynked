//
//  ServiceDetailTableViewCell.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 6/24/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit


class ServiceDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var serviceTitleLabel: UILabel!
    
    @IBOutlet weak var serviceTextField: UITextField!
    
    @IBOutlet weak var fixedToggleSwitch: UISwitch?
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
