//
//  ServiceClass.swift
//  Lynked
//
//  Created by Matthew Singleton on 1/25/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import Foundation

class ServiceClass {

    
    var serviceID: String
    var cardID: String
    var serviceName: String?
    var serviceUrl: String?
    var serviceStatus: Bool?
    var serviceFixed: Bool?
    var serviceAmount: Double = 0
    var serviceAttention: Int = 0 
    
    
    init(id: String, cardId: String, serviceDict: [String : Any]) {
        serviceID = id
        self.cardID = cardId
        serviceName = serviceDict["serviceName"] as? String
        serviceUrl = serviceDict["serviceURL"] as? String
        serviceStatus = serviceDict["serviceStatus"] as? Bool
        
        serviceFixed = serviceDict["serviceFixed"] as? Bool
        
        if let amount = serviceDict["serviceAmount"] as? Double {
            serviceAmount = amount
        }
        if let tempAtten = serviceDict["attentionInt"] as? Int {
            serviceAttention = tempAtten
        }
    }
  
}


