//
//  UIView+Extensions.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 6/18/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import Foundation
import UIKit

private var materialKey = false

extension UIView {

    @IBInspectable var materialDesign: Bool {
        
        get {
            
            return materialKey
            
        } set {
            
            materialKey = newValue
            
            if materialKey {
                
                self.layer.masksToBounds = false
                self.layer.cornerRadius = 3.0
                self.layer.shadowOpacity = 0.8
                self.layer.shadowRadius = 3.0
                self.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
                self.layer.shadowColor = UIColor(red: 157.0/255.0, green: 157.0/255.0, blue: 157.0/255.0, alpha: 1.0).cgColor
            }
        }
    }
    
    func createRoundView() {
        layer.cornerRadius = frame.size.width/2
        clipsToBounds = true
        layer.masksToBounds = true
    }
    
    func createRoundedCorners() {
        layer.cornerRadius = 7
        clipsToBounds = true
    }
}
