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
  
  
  private let colors = [[SegmentKeys.type : 0, SegmentKeys.color : UIColor.init(red: 181.0/255.0, green: 49.0/255.0, blue: 59.0/255.0, alpha: 1.0)],
                        [SegmentKeys.type : 0, SegmentKeys.color : UIColor.init(red: 0.0/255.0, green: 97.0/255.0, blue: 36.0/255.0, alpha: 1.0)],
                        [SegmentKeys.type : 0, SegmentKeys.color : UIColor.init(red: 33.0/255.0, green: 91.0/255.0, blue: 158.0/255.0, alpha: 1.0)],
                        [SegmentKeys.type : 0, SegmentKeys.color : UIColor.init(red: 41.0/255.0, green: 40.0/255.0, blue: 35.0/255.0, alpha: 1.0)],
                        [SegmentKeys.type : 1, SegmentKeys.color : UIColor.init(red: 213.0/255.0, green: 212.0/255.0, blue: 219.0/255.0, alpha: 1.0)],
                        [SegmentKeys.type : 1, SegmentKeys.color : UIColor.init(red: 197.0/255.0, green: 179.0/255.0, blue: 88.0/255.0, alpha: 1.0)]]
  
  
  func colorAtIndex(index: Int) -> UIColor {
    if index < colors.count {
      if let color = colors[index][SegmentKeys.color] as? UIColor {
        return color
      }
    }
    return UIColor.white
  }
  
  
  func textColorAtIndex(index: Int) -> UIColor {
    if index < colors.count {
      if let colorNumber = colors[index][SegmentKeys.type] as? Int {
        return colorNumber == 0 ? UIColor.white : UIColor.black
      }
    }
    return UIColor.black
  }
  
  
  
  private let cardImages = [[SegmentKeys.type : 0, SegmentKeys.img : #imageLiteral(resourceName: "RedCard")],
                            [SegmentKeys.type : 0, SegmentKeys.img : #imageLiteral(resourceName: "Green Card")],
                            [SegmentKeys.type : 0, SegmentKeys.img : #imageLiteral(resourceName: "Blue Card")],
                            [SegmentKeys.type : 0, SegmentKeys.img : #imageLiteral(resourceName: "Black Card")],
                            [SegmentKeys.type : 1, SegmentKeys.img : #imageLiteral(resourceName: "Silver Card")],
                            [SegmentKeys.type : 1, SegmentKeys.img : #imageLiteral(resourceName: "Gold Card")]]
  
  
  
  
  func imageAtIndex(index: Int) -> UIImage {
    if index < cardImages.count {
      if let img = cardImages[index][SegmentKeys.img] as? UIImage {
        return img
      }
    }
    return #imageLiteral(resourceName: "Silver Card")
  }
  
  
  
  
}
