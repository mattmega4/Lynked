//
//  ServiceCategoryTableViewCell.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 6/21/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit

class ServiceCategoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var serviceCategoryLabel: UILabel!
    @IBOutlet weak var serviceCategoryPicker: UIPickerView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
