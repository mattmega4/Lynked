//
//  ServiceClass.swift
//  Lynked
//
//  Created by Matthew Singleton on 1/25/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import Foundation

class ServiceClass {

    
    var serviceID: String?
    var serviceName: String?
    var serviceUrl: String?
    var serviceStatus: Bool?
    var serviceFixed: Bool?
    var serviceAmount: String?
    var serviceAttention: Int = 0
    
    
    init(serviceDict: [String : Any]) {
        
        serviceName = serviceDict["serviceName"] as? String
        serviceUrl = serviceDict["serviceURL"] as? String
        serviceStatus = serviceDict["serviceStatus"] as? Bool
        
        serviceFixed = serviceDict["serviceFixed"] as? Bool
        
        serviceAmount = serviceDict["serviceAmount"] as? String
        if let tempAtten = serviceDict["attentionInt"] as? Int {
            serviceAttention = tempAtten
        }
    }
  
}


