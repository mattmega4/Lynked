//
//  Card.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 7/28/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit

class Card: NSObject {
  
  var cardID: String
  var nickname: String?
  var fourDigits: String?
  var type: String?
  var colorIndex = 0
  var color: UIColor?
  var image: UIImage?
  var textColor: UIColor?
  
  init(id: String, cardDict: [String: Any]) {
    cardID = id
    nickname = cardDict[FirebaseKeys.nickname] as? String
    fourDigits = cardDict[FirebaseKeys.last4] as? String
    type = cardDict[FirebaseKeys.type] as? String
    if let theIndex = cardDict[FirebaseKeys.color] as? Int {
      colorIndex = theIndex
      //            color = SegmentColorManager.shared.colorAtIndex(index: theIndex)
      image = SegmentColorManager.shared.imageAtIndex(index: theIndex)
      
      textColor = SegmentColorManager.shared.textColorAtIndex(index: theIndex)
    }
  }
  
  
  
}
