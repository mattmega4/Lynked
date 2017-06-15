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
    
    private let colors = [["type" : 0, "color" : UIColor.red], ["type" : 0, "color" : UIColor.green], ["type" : 0, "color" : UIColor.blue], ["type" : 0, "color" : UIColor.black], ["type" : 1, "color" : UIColor.gray], ["type" : 1, "color" : UIColor.yellow]]
    
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
