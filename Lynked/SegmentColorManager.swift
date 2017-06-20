//
//  SegmentColorManager.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 6/14/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit

class SegmentColorManager: NSObject {
    
    static let shared = SegmentColorManager()
    
    
    private let colors = [["type" : 0, "color" : UIColor.init(red: 181.0/255.0, green: 49.0/255.0, blue: 59.0/255.0, alpha: 1.0)],
                          ["type" : 0, "color" : UIColor.init(red: 0.0/255.0, green: 97.0/255.0, blue: 36.0/255.0, alpha: 1.0)],
                          ["type" : 0, "color" : UIColor.init(red: 33.0/255.0, green: 91.0/255.0, blue: 158.0/255.0, alpha: 1.0)],
                          ["type" : 0, "color" : UIColor.init(red: 41.0/255.0, green: 40.0/255.0, blue: 35.0/255.0, alpha: 1.0)],
                          ["type" : 1, "color" : UIColor.init(red: 213.0/255.0, green: 212.0/255.0, blue: 219.0/255.0, alpha: 1.0)],
                          ["type" : 1, "color" : UIColor.init(red: 197.0/255.0, green: 179.0/255.0, blue: 88.0/255.0, alpha: 1.0)]]
    
    func colorAtIndex(index: Int) -> UIColor {
        if index < colors.count {
            if let color = colors[index]["color"] as? UIColor {
                return color
            }
        }
        return UIColor.white
    }
    
    func textColorAtIndex(index: Int) -> UIColor {
        if index < colors.count {
            if let colorNumber = colors[index]["type"] as? Int {
                return colorNumber == 0 ? UIColor.white : UIColor.black
            }
        }
        return UIColor.black
    }
    
}
