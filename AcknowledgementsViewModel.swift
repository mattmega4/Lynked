//
//  AcknowledgementsViewModel.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 6/18/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit

class AcknowledgementsViewModel: NSObject {

    
    func getAcknowlwdgements() -> [Library] {
        if let path = Bundle.main.path(forResource: "Pods-Lynked-acknowledgements", ofType: "plist") {
            if let ackDic = NSDictionary(contentsOfFile: path) as? [String : Any] {
                if let ackArray = ackDic["PreferenceSpecifiers"] as? [[String : String]] {
                    var libraries = ackArray.map({ (dic) -> Library in
                        return Library(object: dic)
                    })
                    libraries.remove(at: 0)
                    return libraries
                
                }
            }
        }
        return [Library]()
    }
    
    func getVersionInfo() -> String? {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return "Lynked Version: \(version)"
        }
        return nil
    }

}
