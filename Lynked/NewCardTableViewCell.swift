//
//  NewCardTableViewCell.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 6/25/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit

class NewCardTableViewCell: UITableViewCell {

    @IBOutlet weak var cardBorderView: UIView!
    @IBOutlet weak var cardBackgroundView: UIView!
    @IBOutlet weak var newCardLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.cardBorderView.layoutIfNeeded()
        self.cardBorderView.createRoundView()
        
        self.cardBackgroundView.layoutIfNeeded()
        self.cardBackgroundView.createRoundView()
        
    }
    
}
