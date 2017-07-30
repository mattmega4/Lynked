//
//  CategoryManager.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 6/23/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit

class Category: NSObject {
  
  var id = 0
  var name: String?
  var services = [Service]()
  
}

class CategoryManager: NSObject {
  
  
  static let shared = CategoryManager()
  
  
  let categories = ["Miscellaneous",
                    "Entertainment",
                    "Utilities",
                    "Food",
                    "Professional",
                    "Charity",
                    "Shopping",
                    "Education",
                    "Travel",
                    "Medical"]
  
}




