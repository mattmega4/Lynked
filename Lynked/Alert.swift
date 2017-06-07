//
//  Alert.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 6/6/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlertWith(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
}
