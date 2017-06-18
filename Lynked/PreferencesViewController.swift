//
//  PreferencesViewController.swift
//  Lynked
//
//  Created by Matthew Singleton on 12/14/16.
//  Copyright © 2016 Matthew Singleton. All rights reserved.
//

import UIKit
import Firebase
import StoreKit
import Fabric
import Crashlytics


class PreferencesViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    
    
    let ref = Database.database().reference()
    let user = Auth.auth().currentUser
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Preferences"
        setNavBar()
        showReview()
    }
    

    

    

    
    
    
    
    // MARK:  Delete User Method & Remove All Users Data
    
    func deleteUser() {
        let alertController = UIAlertController(title: "Wait!", message: "This deletes everying tied to your account! All your cards, service, and total fixed monthly expenses You will need to register a new free account!", preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "Never Mind!", style: UIAlertActionStyle.cancel, handler: nil)
        let okAction = UIAlertAction(title: "I Understand!", style: UIAlertActionStyle.default) { (result: UIAlertAction) in
            
            Analytics.logEvent("User_Deleted_Account", parameters: ["success" : true])
            
            Answers.logCustomEvent(withName: "User Deleted Account",
                                   customAttributes: nil)
            
            Auth.auth().currentUser?.delete(completion: { (error) in
                if error == nil {
                    if let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as? EntryViewController {
                        self.navigationController?.pushViewController(loginVC, animated: true)
                    }
                } else {
                    let failedAlert = UIAlertController(title: "Something Went Wrong", message: "We were unable to delete your account. Please try again!", preferredStyle: UIAlertControllerStyle.alert)
                    let okAction = UIAlertAction(title: "OKAY!", style: UIAlertActionStyle.default, handler: nil)
                    failedAlert.addAction(okAction)
                    print((error?.localizedDescription)! as String)
                }
            })
            if let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as? EntryViewController {
                self.navigationController?.pushViewController(loginVC, animated: true)
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    // MARK: IB Actions
    
    
    //    @IBAction func deleteAccountTapped(_ sender: UIButton) {
    //        deleteUser()
    //    }
    
    
    func tempModalPresent() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let ackVC = storyboard.instantiateViewController(withIdentifier: "ackVC")
        self.present(ackVC, animated: true, completion: nil)
        
        
    }
    
} // End of PreferencesViewController Class


