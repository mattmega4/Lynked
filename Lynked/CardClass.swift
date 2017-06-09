//
//  CardClass.swift
//  Lynked
//
//  Created by Matthew Singleton on 1/25/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import Foundation


class CardClass {
  
//  var cardID = ""
//  var nickname = ""
//  var type = ""
//  var cStatus = true

    
    
    var cardID: String?
    var nickname: String?
    var type: String?
    var cStatus = true
    
    init(cardDict: [String: Any]) {
        
        let cardNickname = cardDict["nickname"]
        let cardType = cardDict["type"]
        if let cardStatus = cardDict["cardStatus"] as? Bool {
            cStatus = cardStatus
        }
        
        //cardID = cardID
        nickname = cardNickname as? String
        type = cardType as? String
        
    }
    
}
