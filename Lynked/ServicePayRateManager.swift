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
    
    let payRates = [/*"Weekly",*/
//                    "Biweekly",
                    "Monthly",
//                    "Quarterly",
                    "Annually"]
    
    func getNextPaymentDateFor(service: ServiceClass) -> Date {
        if service.nextPaymentDate.timeIntervalSinceNow > 0 {
            return service.nextPaymentDate
        }
        let cal = Calendar.current
        let day = cal.component(.day, from: service.nextPaymentDate)
        let month = cal.component(.month, from: service.nextPaymentDate)
        var components = DateComponents()
        components.year = cal.component(.year, from: Date())
        components.day = day
        
        let today = cal.component(.day, from: Date())
        if service.paymentRate == "Monthly" {
            if today > day {
                components.month = cal.component(.month, from: Date()) + 1
                if components.month == 2 {
                    if day > 28 {
                        components.day = 28
                    }
                }
                else {
                    if day > 30 {
                        components.day = 30
                    }
                }
                if let theMonth = components.month {
                    if theMonth > 12 {
                        components.month = 1
                        if let theYear = components.year {
                            components.year = theYear + 1
                        }
                    }
                }
            }
            else {
                components.month = cal.component(.month, from: Date())
            }
            if let theDate = cal.date(from: components) {
                return theDate
            }
        }
        else if service.paymentRate == "Annually" {
            let thisMonth = cal.component(.month, from: Date())
            if thisMonth < month {
                components.month = month
            } else {
                components.year = cal.component(.year, from: Date()) + 1
            }
            if let theDate = cal.date(from: components) {
                return theDate
            }
        }
        
        return Date()
    }

}

