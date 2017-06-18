//
//  CardClass.swift
//  Lynked
//
//  Created by Matthew Singleton on 1/25/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit


class CardClass {
    
    var cardID: String?
    var nickname: String?
    var fourDigits: String?
    var type: String?
    var color: UIColor?
    var textColor: UIColor?
    
    
    init(cardDict: [String: Any]) {
        
        nickname = cardDict["nickname"] as? String
        fourDigits = cardDict["last4"] as? String
        type = cardDict["type"] as? String
        if let colorIndex = cardDict["color"] as? Int {
            color = SegmentColorManager.shared.colorAtIndex(index: colorIndex)
            textColor = SegmentColorManager.shared.textColorAtIndex(index: colorIndex)
        }
        
        
        
        //let cardType = cardDict["type"]
        //let cardFourDigits = cardDict["last4"]
        //        fourDigits = cardFourDigits as? String
        //        type = cardType as? String
        
        
        //        nickname = cardNickname as? String
        //        let cardNickname = cardDict["nickname"]
        
    }
    
}
