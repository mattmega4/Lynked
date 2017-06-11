//
//  CardClass.swift
//  Lynked
//
//  Created by Matthew Singleton on 1/25/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import Foundation


class CardClass {

    var cardID: String?
    var nickname: String?
    var fourDigits: String?
    var type: String?

    
    init(cardDict: [String: Any]) {
        
        let cardNickname = cardDict["nickname"]
        let cardFourDigits = cardDict["last4"]
        let cardType = cardDict["type"]
        


        nickname = cardNickname as? String
        fourDigits = cardFourDigits as? String
        type = cardType as? String
        
    }
    
}
