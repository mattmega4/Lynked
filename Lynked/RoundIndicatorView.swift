//
//  RoundIndicatorView.swift
//  Lynked
//
//  Created by Matthew Singleton on 12/14/16.
//  Copyright © 2016 Matthew Singleton. All rights reserved.
//

import UIKit


extension UIView {
  
  func roundIndicationViewInCell() {
    
    layer.cornerRadius = frame.size.width/2
    clipsToBounds = true
    
  }
  
  
}
