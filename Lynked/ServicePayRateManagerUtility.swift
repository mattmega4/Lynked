//
//  ServicePayRateManagerUtility.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 8/2/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit

class ServicePayRateManagerUtility: NSObject {

  static let shared = ServicePayRateManagerUtility()
  
  let payRates = [/*"Weekly",*/
    //                    "Biweekly",
    "Monthly",
    //                    "Quarterly",
    "Annually"]
  
  func getNextPaymentDateFor(service: Service) -> Date? {
    if let theDate = service.nextPaymentDate {
      if theDate.timeIntervalSinceNow > 0 {
        return service.nextPaymentDate
      }
      let cal = Calendar.current
      let day = cal.component(.day, from: theDate)
      let month = cal.component(.month, from: theDate)
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
          } else {
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
        } else {
          components.month = cal.component(.month, from: Date())
        }
        if let theDate = cal.date(from: components) {
          return theDate
        }
      } else if service.paymentRate == "Annually" {
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
    }
    
    return nil
  }
  

  
}
