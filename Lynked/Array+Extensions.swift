//
//  Array+Extensions.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 6/18/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import Foundation
import UIKit

extension Array where Element: Hashable {
    func countForElements() -> [(Element, Int)] {
        let countedSet = NSCountedSet(array: self)
        let res = countedSet.objectEnumerator().map { (object: Any) -> (Element, Int) in
            return (object as! Element, countedSet.count(for: object))
        }
        return res
    }
}
