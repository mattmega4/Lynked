//
//  Service.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 7/28/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit

class Service: NSObject {
  
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
    serviceName = serviceDict[FirebaseKeys.serviceName] as? String
    serviceUrl = serviceDict[FirebaseKeys.serviceURL] as? String
    if let theStatus = serviceDict[FirebaseKeys.serviceStatus] as? Bool {
      serviceStatus = theStatus
    }
    
    serviceFixed = serviceDict[FirebaseKeys.serviceFixed] as? Bool
    
    if let amount = serviceDict[FirebaseKeys.serviceAmount] as? Double {
      serviceAmount = amount
    }
    if let tempAtten = serviceDict[FirebaseKeys.attentionInt] as? Int {
      serviceAttention = tempAtten
    }
    
    if let payDate = serviceDict[FirebaseKeys.nextPaymentDate] as? Double {
      nextPaymentDate = Date(timeIntervalSince1970: payDate)
      
      //            nextPaymentDate = ServicePayRateManager.shared.getNextPaymentDateFor(service: self)
      
    }
    
    category = serviceDict[FirebaseKeys.category] as? String
    
    paymentRate = serviceDict[FirebaseKeys.paymentRate] as? String
    
    
  }
  
  
  
}
