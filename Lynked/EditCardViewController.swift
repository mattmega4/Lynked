//
//  EditCardViewController.swift
//  Lynked
//
//  Created by Matthew Singleton on 12/11/16.
//  Copyright © 2016 Matthew Singleton. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import Fabric
import Crashlytics

class EditCardViewController: UIViewController {
    
    @IBOutlet weak var leftNavBarButton: UIBarButtonItem!
    @IBOutlet weak var rightNavBarButton: UIBarButtonItem!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var lyLogo: UIImageView!
    @IBOutlet weak var segControl: UISegmentedControl!
    
    @IBOutlet weak var firstDividerView: UIView!
    @IBOutlet weak var secondDividerView: UIView!
    @IBOutlet weak var thirdDividerView: UIView!
    
    @IBOutlet weak var firstContainerView: UIView!
    @IBOutlet weak var secondContainerView: UIView!
    @IBOutlet weak var thirdContainerView: UIView!
    
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var digitsLabel: UILabel!
    @IBOutlet weak var alteredButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var digitsTextField: UITextField!
    
    
    
    var nicknameFieldSatisfied: Bool?
    var typeFieldSatisfied: Bool?
    var thisCardIDTransfered = ""
    var last4Pulled: String?
    var cardType: String?
    var serviceToDelete: [String] = []
    var stateOfCard: Bool?
    
    var colorInt: Int?
    var cardID: String?
    var cardDeleted = false
    
    var card: CardClass?
    var serviceArray = [ServiceClass]()
    
    let ref = Database.database().reference()
    let user = Auth.auth().currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nicknameTextField.delegate = self
        self.digitsTextField.delegate = self
        
        lyLogo.createRoundView()
        
        title = "Edit Card"
        setNavBar()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EditCardViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        leftNavBarButton.isEnabled = true
        rightNavBarButton.isEnabled = true
        //pullCardData()
        populateCardInfo()
    }
    
    func populateCardInfo() {
        segControl.selectedSegmentIndex = card?.colorIndex ?? 0
        nicknameTextField.text = card?.nickname
        digitsTextField.text = card?.fourDigits
    }
    
    
    // MARK: - Card Was Altered with Alert
    
    func changeStatusOfCardAndServices() { // reset all services to needs attention
        
        let alertController = UIAlertController(title: "Something went wrong!", message: "This will mark all linked services as 'needs attention.' You will have to update each service one at a time!", preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "Never Mind!", style: UIAlertActionStyle.cancel, handler: nil)
        
        let okAction = UIAlertAction(title: "I Understand!", style: UIAlertActionStyle.default) { (result: UIAlertAction) in
            FirebaseUtility.shared.resetServices(services: self.serviceArray) { (services) in
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    // MARK: - Delete Card with UIAlert
    
    func deleteCard() {
        
        let alertController = UIAlertController(title: "Wait!", message: "This will completely remove this card from your account. All the services linked to this card will be removed. Your total fixed monthly expenses will also be erased!", preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "Never Mind!", style: .cancel, handler: nil)
        
        let okAction = UIAlertAction(title: "I Understand!", style: .destructive) { (result: UIAlertAction) in
            
            guard let theCard = self.card else {
                return
            }
            FirebaseUtility.shared.delete(card: theCard, completion: { (success, error) in
                if let errorMessage = error {
                    print(errorMessage)
                } else if success {
                    var didGoBack = false
                    if let viewControllers = self.navigationController?.viewControllers {
                        for aController in viewControllers {
                            if aController is WalletViewController {
                                didGoBack = true
                                self.navigationController?.popToViewController(aController, animated: true)
                                break
                            }
                        }
                        
                    }
                    if !didGoBack {
                        if let walletVC = self.storyboard?.instantiateViewController(withIdentifier: "WalletVC") as? WalletViewController {
                            self.navigationController?.pushViewController(walletVC, animated: true)
                        }
                    }
                }
            })
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    // MARK: - Update Card
    
    func updateCard() {
        guard let theCard = card else {
            return
        }
        
        FirebaseUtility.shared.update(card: theCard,
                                      nickName: nicknameTextField.text,
                                      last4: digitsTextField.text,
                                      color: segControl.selectedSegmentIndex) { (updatedCard, error) in
                                        
                                        self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    // MARK: - IB Actions
    
    @IBAction func leftBarButtonTapped(_ sender: UIBarButtonItem) {
        leftNavBarButton.isEnabled = false
        if let detailVC = storyboard?.instantiateViewController(withIdentifier: "servieVC") as? ServicesViewController {
            detailVC.card = card
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func rightBarButtonTapped(_ sender: UIBarButtonItem) {
        updateCard()
        rightNavBarButton.isEnabled = false
    }
    
    @IBAction func alteredButtonTapped(_ sender: UIButton) {
        changeStatusOfCardAndServices()
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        deleteCard()
    }
    
    
    // MARK: - Keyboard Methods
    
    func keyboardWillShow(notification:NSNotification) {
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        var contentInset: UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 30
        self.scrollView.contentInset = contentInset
    }
    
    
    func keyboardWillHide(notification:NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInset
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        textField.resignFirstResponder()
        return false
    }
    
    
} // MARK: - End of EditCardViewController


extension EditCardViewController: UITextFieldDelegate {
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == digitsTextField {
            
            guard let text = textField.text else { return true }
            
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            
            let newLength = text.characters.count + string.characters.count - range.length
            return  allowedCharacters.isSuperset(of: characterSet) && newLength <= 4 // Bool
        }
        
        return true
    }
    
}
