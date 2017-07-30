//
//  ServiceTableViewCell.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 7/3/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit

class ServiceTableViewCell: UITableViewCell {
  
  @IBOutlet weak var topDividerView: UIView!
  
  @IBOutlet weak var serviceLogoImageVIew: UIImageView!
  @IBOutlet weak var serviceNameLabel: UILabel!
  @IBOutlet weak var serviceCategoryLabel: UILabel!
  @IBOutlet weak var serviceAmountLabel: UILabel!
  @IBOutlet weak var serviceDueDateLabel: UILabel!
  @IBOutlet weak var leftDividerView: UIView!
  @IBOutlet weak var serviceColorStatusView: UIView!
  @IBOutlet weak var bottomDividerView: UIView!
    
}
