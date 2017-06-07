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


class PreferencesViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var rightNavBarButton: UIBarButtonItem!
    
    @IBOutlet weak var cardCountTitleLabel: UILabel!
    @IBOutlet weak var cardCountLabel: UILabel!
    @IBOutlet weak var purchaseCardButton: UIButton!
    
    
    @IBOutlet weak var firstDividerView: UIView!
    @IBOutlet weak var secondDividerView: UIView!
    @IBOutlet weak var thirdDividerView: UIView!
    
    @IBOutlet weak var firstContainerView: UIView!
    @IBOutlet weak var secondContainerView: UIView!
    
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
        title = "Preferences"
        navigationController?.navigationBar.barTintColor = UIColor(red: 108.0/255.0,
                                                                   green: 158.0/255.0,
                                                                   blue: 236.0/255.0,
                                                                   alpha: 1.0)
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white,
                                                                   NSFontAttributeName: UIFont(name: "GillSans-Bold",
                                                                                               size: 20)!]
    }
    
    
    // MARK:  Delete User Method & Remove All Users Data
    
    func deleteUser() {
        let alertController = UIAlertController(title: "Wait!", message: "This deletes everying tied to your account! All your cards, service, and total fixed monthly expenses You will need to register a new free account!", preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "Never Mind!", style: UIAlertActionStyle.cancel, handler: nil)
        let okAction = UIAlertAction(title: "I Understand!", style: UIAlertActionStyle.default) { (result: UIAlertAction) in
            Auth.auth().currentUser?.delete(completion: { (error) in
                if error == nil {
                    // TODO: In V2 actually remove the data from Firebase
                    self.performSegue(withIdentifier: "fromPrefToSignIn", sender: self)
                } else {
                    let failedAlert = UIAlertController(title: "Something Went Wrong", message: "We were unable to delete your account. Please try again!", preferredStyle: UIAlertControllerStyle.alert)
                    let okAction = UIAlertAction(title: "OKAY!", style: UIAlertActionStyle.default, handler: nil)
                    failedAlert.addAction(okAction)
                    print((error?.localizedDescription)! as String)
                }
            })
            self.performSegue(withIdentifier: "fromPrefToSignIn", sender: self)
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
    
    
    @IBAction func rightNavBarButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    //
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
    
    
    
    //
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
        performSegue(withIdentifier: "fromPrefToSignIn", sender: self)
    }
    
    @IBAction func deleteAccountTapped(_ sender: UIButton) {
        deleteUser()
    }
    
}

// End of PreferencesViewController Class


