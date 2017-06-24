//
//  ServicePayRateManager.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 6/23/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit

class ServicePayRateManager: NSObject {
    
    static let shared = ServicePayRateManager()
    
    let payRates = ["Weekly",
                    "Biweekly",
                    "Monthly",
                    "Quarterly",
                    "Annually"]

}

