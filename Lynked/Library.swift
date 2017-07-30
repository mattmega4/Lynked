//
//  Library.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 6/18/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit

class Library: NSObject {
  
  var name: String?
  var legalDescription: String?
  
  init(object: [String : String]) {
    name = object["Title"]
    legalDescription = object["FooterText"]
  }
}
