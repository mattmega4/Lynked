//
//  ProfileViewController.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 7/2/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit
import Firebase
import Instabug

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var profileViewBorder: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    
    @IBOutlet weak var leftSideButton: UIButton!
    @IBOutlet weak var rightSideButton: UIButton!
    
    @IBOutlet weak var rightViewContainer: UIView!
    @IBOutlet weak var feedbackButton: UIButton!
    @IBOutlet weak var acknowledgementsButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    let ref = Database.database().reference()
    let user = Auth.auth().currentUser
    
//    let storage = Storage.storage()
    
    var leftOnRightOff = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Profile"
        setNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
    
    
    //MARK: - IBActions
    
    
    @IBAction func feedbackButtonTapped(_ sender: UIButton) {
        Instabug.invoke()
        Instabug.setCommentFieldRequired(true)
        Instabug.setEmailFieldRequired(false)
    }
    
    @IBAction func acknowledgementsButtonTapped(_ sender: UIButton) {
        if let ackVC = self.storyboard?.instantiateViewController(withIdentifier: ACKNOWLEDGEMENTS_STORYBOARD_IDENTIFIER) as? AcknowledgementsViewController {
            self.navigationController?.pushViewController(ackVC, animated: true)
        }
    }
    
    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            
            if let loginVC = self.storyboard?.instantiateViewController(withIdentifier: ENTRY_STORYBOARD_IDENTIFIER) as? EntryViewController {
                self.navigationController?.pushViewController(loginVC, animated: true)
            }
            
        }
        catch {
            debugPrint(error)
        }
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Wait!", message: "This deletes everying tied to your account! All your cards, service, and total fixed monthly expenses You will need to register a new free account!", preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "Never Mind!", style: UIAlertActionStyle.cancel, handler: nil)
        let okAction = UIAlertAction(title: "I Understand!", style: UIAlertActionStyle.default) { (result: UIAlertAction) in
            self.user?.delete { error in
                if let error = error {
                    debugPrint(error)
                } else {
                    if let loginVC = self.storyboard?.instantiateViewController(withIdentifier: ENTRY_STORYBOARD_IDENTIFIER) as? EntryViewController {
                        self.navigationController?.pushViewController(loginVC, animated: true)
                    }
                }
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    
}
