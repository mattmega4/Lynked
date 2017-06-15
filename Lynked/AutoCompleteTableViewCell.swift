//
//  AutoCompleteTableViewCell.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 6/14/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit

class AutoCompleteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var previewNameLabel: UILabel!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
