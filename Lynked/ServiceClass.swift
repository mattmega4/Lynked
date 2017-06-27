//
//  ServiceClass.swift
//  Lynked
//
//  Created by Matthew Singleton on 1/25/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import Foundation
import UIKit


class ServiceClass {

    
    var serviceID: String
    var cardID: String
    var serviceName: String?
    var serviceUrl: String?
    var serviceStatus = true
    var serviceFixed: Bool?
    var serviceAmount: Double = 0
    var serviceAttention: Int = 0
    
    var nextPaymentDate: Date?
    var category: String?
    var paymentRate: String?
    
    init(id: String, cardId: String, serviceDict: [String : Any]) {
        serviceID = id
        self.cardID = cardId
        serviceName = serviceDict["serviceName"] as? String
        serviceUrl = serviceDict["serviceURL"] as? String
        if let theStatus = serviceDict["serviceStatus"] as? Bool {
            serviceStatus = theStatus
        }
        
        serviceFixed = serviceDict["serviceFixed"] as? Bool
        
        if let amount = serviceDict["serviceAmount"] as? Double {
            serviceAmount = amount
        }
        if let tempAtten = serviceDict["attentionInt"] as? Int {
            serviceAttention = tempAtten
        }
        
        if let payDate = serviceDict["nextPaymentDate"] as? Double {
            nextPaymentDate = Date(timeIntervalSince1970: payDate)
            nextPaymentDate = ServicePayRateManager.shared.getNextPaymentDateFor(service: self)
        }
        
        category = serviceDict["category"] as? String 
        
        paymentRate = serviceDict["paymentRate"] as? String
        
        
    }
  
}


