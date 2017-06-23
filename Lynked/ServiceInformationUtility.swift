//
//  ServiceInformationUtility.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 6/22/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit

class ServiceInformationUtility: NSObject {
    
    var paymentTimeFrame: [String] = []
    
    
    static let shared = ServiceInformationUtility()
    
    
    func addToPaymentTimeFrameArray() {
        paymentTimeFrame+=["Weekly", "Biweekly", "Monthly", "Quarterly", "Annually"]
    }
    
    

}
