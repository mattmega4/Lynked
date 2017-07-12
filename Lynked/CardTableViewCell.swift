//
//  CardTableViewCell.swift
//  Lynked
//
//  Created by Matthew Singleton on 1/22/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit

class CardTableViewCell: UITableViewCell {
  
  
  @IBOutlet weak var cardBorderView: UIView!
  @IBOutlet weak var cardBackgroundView: UIView!
  
  @IBOutlet weak var cardNicknameLabel: UILabel!
  @IBOutlet weak var cardDetailsLabel: UILabel!

  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.cardBorderView.layoutIfNeeded()
        self.cardBorderView.createRoundedCorners()
        
        self.cardBackgroundView.layoutIfNeeded()
        self.cardBackgroundView.createRoundedCorners()
        
    }
    
    
}
