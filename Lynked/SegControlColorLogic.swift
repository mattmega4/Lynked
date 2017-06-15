////
////  SegControlColorLogic.swift
////  Lynked
////
////  Created by Matthew Howes Singleton on 6/14/17.
////  Copyright © 2017 Matthew Singleton. All rights reserved.
////
//
//import UIKit
//
//class SegControlColorLogic: UISegmentedControl {
//
//    
//    
//    static let shared = SegControlColorLogic()
//    
//    override init() {
//        super.init()
//        
//        var seg = UISegmentedControl() /// ?
//    }
//    
//    
//    
//    var clr: UIColor = .red
//    
//    let segAttributes: NSDictionary = [
//        NSForegroundColorAttributeName: clr,
//        NSFontAttributeName: UIFont(name: "GillSans-Bold", size: 15)!
//    ]
//    
//    seg.setTitleTextAttributes(segAttributes as [NSObject : AnyObject], for: UIControlState.normal)
//    
//    switch seg.selectedSegmentIndex {
//    
//    case 0:
//    (seg.subviews[0] as UIView).tintColor = .red
//    clr = .white
//    case 1:
//    (seg.subviews[1] as UIView).tintColor = .green
//    clr = .white
//    case 2:
//    (seg.subviews[2] as UIView).tintColor = .blue
//    clr = .white
//    case 3:
//    (seg.subviews[3] as UIView).tintColor = .black
//    clr = .white
//    case 4:
//    (seg.subviews[4] as UIView).tintColor = .gray
//    clr = .black
//    case 5:
//    (seg.subviews[5] as UIView).tintColor = .yellow
//    clr = .black
//    
//    default: break
//    // do i need this since i covered all cases?
//    }
//   
//}
//
//
//
