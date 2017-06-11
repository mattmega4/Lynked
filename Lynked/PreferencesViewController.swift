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
    
    @IBOutlet weak var firstDividerView: UIView!
    @IBOutlet weak var secondDividerView: UIView!
    @IBOutlet weak var thirdDividerView: UIView!
    
    @IBOutlet weak var fourthDividerView: UIView!
    
    @IBOutlet weak var fifthDividerView: UIView!
    
    
    @IBOutlet weak var purchaseCardButton: UIButton!
    
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var deleteAccountButton: UIButton!
    
    @IBOutlet weak var versionLabel: UILabel!
    
    let ref = Database.database().reference()
    let user = Auth.auth().currentUser
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavBar()
        getVersionInfo()
        
    }
    
    // MARK: Nav Bar & View Design
    
    func setNavBar() {
        self.navigationController?.isNavigationBarHidden = false
        title = "Preferences"
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
    
    
    // MARK:  Delete User Method & Remove All Users Data
    
    func deleteUser() {
        let alertController = UIAlertController(title: "Wait!", message: "This deletes everying tied to your account! All your cards, service, and total fixed monthly expenses You will need to register a new free account!", preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "Never Mind!", style: UIAlertActionStyle.cancel, handler: nil)
        let okAction = UIAlertAction(title: "I Understand!", style: UIAlertActionStyle.default) { (result: UIAlertAction) in
            
            Answers.logCustomEvent(withName: "User Deleted Account",
                                   customAttributes: nil)
            
            Auth.auth().currentUser?.delete(completion: { (error) in
                if error == nil {
                    // TODO: In V3 actually remove the data from Firebase
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
    
    
    // MARK: App Version Info
    
    func getVersionInfo() {
        
        
       
    
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.text = "Lynked Version: \(version)"
        }
    }
    
    
    // MARK: IB Actions
    
    
    @IBAction func purchaseCardButtonTapped(_ sender: UIButton) {
        
        InAppPurchaseUtility.shared.purchaseProduct { (success, error) in
            if success {
                self.showAlertWith(title: "Success!", message: "Your purchase was successful")
            }
            else  {
                self.showAlertWith(title: "Purchase Failed!", message: error?.localizedDescription)
            }
        }
        
    }
    
    @IBAction func redeemPurchaseButtonTapped(_ sender: UIButton) {
        InAppPurchaseUtility.shared.restorePurchase { (success, error) in
            if success {
                self.showAlertWith(title: "Success!", message: "Your purchase was successful")
            }
            else  {
                self.showAlertWith(title: "Purchase Failed!", message: error?.localizedDescription)
            }
        }
    }
    
    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        if let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as? EntryViewController {
            self.navigationController?.pushViewController(loginVC, animated: true)
        }
    }
    
    @IBAction func deleteAccountTapped(_ sender: UIButton) {
        deleteUser()
    }
    
}

// End of PreferencesViewController Class


