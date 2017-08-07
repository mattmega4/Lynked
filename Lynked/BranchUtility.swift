//
//  BranchUtility.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 7/2/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit
import Fabric
import Branch

class BranchUtility: NSObject {
  
  static let shared = BranchUtility()
  
  func generateBranchLinkFor(promoCode: String, completion: @escaping (_ link: String?) -> Void) {
    
    let branchUniversalObject: BranchUniversalObject = BranchUniversalObject(canonicalIdentifier: BranchKeys.promoCodeSlashOne)
    branchUniversalObject.title = BranchKeys.promoCode
    branchUniversalObject.contentDescription = BranchKeys.downloadLynked
    branchUniversalObject.addMetadataKey(BranchKeys.code, value: promoCode)
    //branchUniversalObject.addMetadataKey("property2", value: "red")
    
    let linkProperties: BranchLinkProperties = BranchLinkProperties()
    linkProperties.feature = BranchKeys.code
    
    branchUniversalObject.getShortUrl(with: linkProperties) { (url, error) in
      completion(url)
    }
  }
  
}
