//
//  UITextField+Extensions.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 7/2/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import Foundation
import UIKit

extension UITextField{
    @IBInspectable var placeHolderTextColor: UIColor? {
        set {
            let placeholderText = self.placeholder != nil ? self.placeholder! : ""
            attributedPlaceholder = NSAttributedString(string:placeholderText, attributes:[NSForegroundColorAttributeName: newValue!])
        }
        get{
            return self.placeHolderTextColor
        }
    }
}
