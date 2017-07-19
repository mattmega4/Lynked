//
//  CardClass.swift
//  Lynked
//
//  Created by Matthew Singleton on 1/25/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import Foundation
import UIKit


class CardClass {
    
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
        nickname = cardDict["nickname"] as? String
        fourDigits = cardDict["last4"] as? String
        type = cardDict["type"] as? String
        if let theIndex = cardDict["color"] as? Int {
            colorIndex = theIndex
            //            color = SegmentColorManager.shared.colorAtIndex(index: theIndex)
            image = SegmentColorManager.shared.imageAtIndex(index: theIndex)
            
            textColor = SegmentColorManager.shared.textColorAtIndex(index: theIndex)
        }
    }
    
}
