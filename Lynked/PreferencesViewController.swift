//
//  PreferencesViewController.swift
//  Lynked
//
//  Created by Matthew Singleton on 12/14/16.
//  Copyright © 2016 Matthew Singleton. All rights reserved.
//

import UIKit
import Instabug
import Firebase


class PreferencesViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var logoImgView: UIImageView!
    
    @IBOutlet weak var nightModeButton: UIButton!
    @IBOutlet weak var useTouchIDButton: UIButton!
    @IBOutlet weak var feedbackButton: UIButton!
    @IBOutlet weak var acknowledgementsButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    
    let ref = Database.database().reference()
    let user = Auth.auth().currentUser
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Preferences"
        
        nightModeButton.isHidden = true
        useTouchIDButton.isHidden = true
        
        setNavBar()
    }
    
    
    // MARK: -  Delete User Method & Remove All Users Data
    
    func deleteUser() {
        
        let alertController = UIAlertController(title: "Wait!", message: "This deletes everying tied to your account! All your cards, service, and total fixed monthly expenses You will need to register a new free account!", preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "Never Mind!", style: UIAlertActionStyle.cancel, handler: nil)
        
        let okAction = UIAlertAction(title: "I Understand!", style: UIAlertActionStyle.default) { (result: UIAlertAction) in
            
            self.user?.delete { error in
                if let error = error {
                    // An error happened.
                } else {
                    if let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as? EntryViewController {
                        self.navigationController?.pushViewController(loginVC, animated: true)
                    }
                }
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    // MARK: - IB Actions
    
    @IBAction func nightModeButtonTapped(_ sender: UIButton) {
    }
    
    @IBAction func useTouchIDButtonTapped(_ sender: UIButton) {
    }
    
    @IBAction func feedbackButtonTapped(_ sender: UIButton) {
        Instabug.invoke()
        Instabug.setCommentFieldRequired(true)
        Instabug.setEmailFieldRequired(false)
    }
    
    @IBAction func acknowledgementsButtonTapped(_ sender: UIButton) {
        
        if let ackVC = self.storyboard?.instantiateViewController(withIdentifier: "ackVC") as? AcknowledgementsViewController {
            self.navigationController?.pushViewController(ackVC, animated: true)
        }
        
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        deleteUser()
    }
    
    
} // MARK: - End of PreferencesViewController


