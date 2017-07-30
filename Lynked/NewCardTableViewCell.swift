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

  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.cardBorderView.layoutIfNeeded()
    self.cardBorderView.createRoundedCorners()
    
    self.cardBackgroundView.layoutIfNeeded()
    self.cardBackgroundView.createRoundedCorners()
    
  }
  
}
