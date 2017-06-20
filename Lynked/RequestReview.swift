//
//  RequestReview.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 6/17/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import Foundation
import StoreKit


let runIncrementerSetting = "numberOfRuns"
let minimumRunCount = 5


func incrementAppRuns() {
    let usD = UserDefaults()
    let runs = getRunCounts() + 1
    usD.setValuesForKeys([runIncrementerSetting: runs])
    usD.synchronize()
}


func getRunCounts () -> Int {
    let usD = UserDefaults()
    let savedRuns = usD.value(forKey: runIncrementerSetting)
    var runs = 0
    if (savedRuns != nil) {
        runs = savedRuns as! Int
    }
    print("Run Counts are \(runs)")
    return runs
}


func showReview() {
    let runs = getRunCounts()
    if (runs > minimumRunCount) {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            // Fallback on earlier versions
        }
    } else {
        // Runs are not enough to request review
    }
}

