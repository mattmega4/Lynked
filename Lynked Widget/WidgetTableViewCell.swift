//
//  WidgetTableViewCell.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 6/25/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit

class WidgetTableViewCell: UITableViewCell {
    
    @IBOutlet weak var serviceImageView: UIImageView!
    
    @IBOutlet weak var serviceNameLabel: UILabel!
    
    @IBOutlet weak var serviceDateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
