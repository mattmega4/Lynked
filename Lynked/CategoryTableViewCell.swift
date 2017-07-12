//
//  CategoryTableViewCell.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 7/3/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var categoryImageStackView: UIStackView!
    @IBOutlet weak var categoryImageOne: UIImageView!
    @IBOutlet weak var categoryImageTwo: UIImageView!
    @IBOutlet weak var categoryImageThree: UIImageView!
    @IBOutlet weak var categoryImageFour: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
