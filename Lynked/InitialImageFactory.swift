//
//  InitialImageFactory.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 7/29/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit

class InitialImageFactory: NSObject {
  
  class func imageWith(name: String?) -> UIImage? {
    let frame = CGRect(x: 0, y: 0, width: 50, height: 50)
    let nameLabel = UILabel(frame: frame)
    nameLabel.textAlignment = .center
    nameLabel.backgroundColor = .lightGray
    nameLabel.textColor = .white
    nameLabel.font = UIFont.boldSystemFont(ofSize: 20)
    var initials = ""
    
    if let letter = name?.first {
      initials += String(letter).capitalized
    } else {
      return nil
    }
    nameLabel.text = initials
    UIGraphicsBeginImageContext(frame.size)
    if let currentContext = UIGraphicsGetCurrentContext() {
      nameLabel.layer.render(in: currentContext)
      let nameImage = UIGraphicsGetImageFromCurrentImageContext()
      return nameImage
    }
    return nil
  }
  
  
}
