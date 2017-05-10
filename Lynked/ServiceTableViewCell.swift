//
//  ServiceTableViewCell.swift
//  Lynked
//
//  Created by Matthew Singleton on 12/14/16.
//  Copyright © 2016 Matthew Singleton. All rights reserved.
//

import UIKit

class ServiceTableViewCell: UITableViewCell {

  
  @IBOutlet weak var topDividerView: UIView!
  @IBOutlet weak var serviceLogoImage: UIImageView!
  @IBOutlet weak var serviceNameLabel: UILabel!
  @IBOutlet weak var serviceStatusView: UIView!
  @IBOutlet weak var bottomDividerView: UIView!
  
  
    override func awakeFromNib() {
        super.awakeFromNib()
      
        // Initialization code
  }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
