//
//  General+Extensions.swift
//  Lynked
//
//  Created by Matthew Singleton on 12/28/16.
//  Copyright © 2016 Matthew Singleton. All rights reserved.
//

import Foundation
import UIKit
import Firebase


extension UIViewController {
    func showAlertWith(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func setNavBar() {
        self.navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.barTintColor = UIColor(red: 108.0/255.0,
                                                                   green: 158.0/255.0,
                                                                   blue: 236.0/255.0,
                                                                   alpha: 1.0)
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white,
                                                                   NSFontAttributeName: UIFont(name: "GillSans-Bold",
                                                                                               size: 18)!]
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension String {
    func validateEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
    }
    
    
    func validateUrl() -> Bool {
        let urlRegEx = "((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+"
        return NSPredicate(format: "SELF MATCHES %@", urlRegEx).evaluate(with: self)
    }
    
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
    
}

extension UIView {
    func createRoundView() {
        layer.cornerRadius = frame.size.width/2
        clipsToBounds = true
    }
}

extension NSObject {
    func delay(_ delay:Double, closure:@escaping ()->()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
}

extension Array where Element: Hashable {
    func countForElements() -> [(Element, Int)] {
        let countedSet = NSCountedSet(array: self)
        let res = countedSet.objectEnumerator().map { (object: Any) -> (Element, Int) in
            return (object as! Element, countedSet.count(for: object))
        }
        return res
    }
}
