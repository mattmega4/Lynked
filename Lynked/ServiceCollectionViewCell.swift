//
//  ServiceCollectionViewCell.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 5/14/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit

class ServiceCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var backgroundViewContainer: UIView!
    @IBOutlet weak var serviceLogoImage: UIImageView!
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var serviceFixedAmountLabel: UILabel!
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.backgroundViewContainer.layoutIfNeeded()       // add this
        self.backgroundViewContainer.layer.cornerRadius = min(backgroundViewContainer.frame.size.width, backgroundViewContainer.frame.size.height)/2
        self.backgroundViewContainer.clipsToBounds = true
        
    }
    
}
