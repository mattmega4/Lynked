//
//  ServiceClass.swift
//  Lynked
//
//  Created by Matthew Singleton on 1/25/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import Foundation

class ServiceClass {
  
//  var serviceID = ""
//  var serviceName = ""
//  var serviceUrl = ""
//  var serviceStatus: Bool?
//  var serviceFixed: Bool?
//  var serviceAmount = ""
//  var serviceAttention: Int = 0
    
    
    
    
    var serviceID: String?
    var serviceName: String?
    
    var serviceUrl: String?
    var serviceStatus: Bool?
    var serviceFixed: Bool?
    var serviceAmount: String?
    var serviceAttention: Int = 0
    
    
    init(serviceDict: [String : Any]) {
        
        serviceUrl = serviceDict["serviceURL"] as? String
        serviceName = serviceDict["serviceName"] as? String
        serviceAmount = serviceDict["serviceAmount"] as? String
        serviceStatus = serviceDict["serviceStatus"] as? Bool
        serviceAttention = (serviceDict["attentionInt"] as? Int)!
    }
  
}

