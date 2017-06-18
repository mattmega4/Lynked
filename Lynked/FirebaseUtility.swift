//
//  FirebaseUtility.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 6/17/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit
import Firebase

class FirebaseUtility: NSObject {
    
    static let shared = FirebaseUtility()
    
    
    
    
    
    

}



//let connectedRef = Database.database().reference(withPath: ".info/connected")
//
//func checkFirebaseConnection() {
//    connectedRef.observe(.value, with: { snapshot in
//        if snapshot.value as? Bool ?? false {
//            print("Connected")
//        } else {
//            print("Not connected")
//        }
//    })
//}
