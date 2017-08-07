//
//  CategoryManagerUtility.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 8/2/17.
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
  
  
  let categories = [CategoryKeys.miscellaneous,
                    CategoryKeys.entertainment,
                    CategoryKeys.utilities,
                    CategoryKeys.food,
                    CategoryKeys.professional,
                    CategoryKeys.charity,
                    CategoryKeys.shopping,
                    CategoryKeys.education,
                    CategoryKeys.travel,
                    CategoryKeys.medical]
  
}




