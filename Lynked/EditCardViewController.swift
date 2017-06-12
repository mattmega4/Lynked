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
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var lyLogo: UIImageView!
    
    @IBOutlet weak var leftNavBarButton: UIBarButtonItem!
    @IBOutlet weak var rightNavBarButton: UIBarButtonItem!
    @IBOutlet weak var firstDividerView: UIView!
    @IBOutlet weak var secondDividerView: UIView!
    @IBOutlet weak var thirdDividerView: UIView!
    @IBOutlet weak var fourthDividerView: UIView!
    @IBOutlet weak var firstContainerView: UIView!
    @IBOutlet weak var secondContainerView: UIView!
    @IBOutlet weak var thirdContainerView: UIView!
    @IBOutlet weak var warningLabel: UILabel!
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
    var serviceToDelete: [String] = []
    var stateOfCard: Bool?
    
    var cardDeleted = false
    
    let ref = Database.database().reference()
    let user = Auth.auth().currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nicknameTextField.delegate = self
        self.digitsTextField.delegate = self
        
        lyLogo.createRoundView()
        
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
        pullCardData()
    }
    
    
    // MARK: Nav Bar & View Design
    
    func setNavBar() {
        self.navigationController?.isNavigationBarHidden = false
        title = "Edit Card"
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
    
    
    // MARK: Firebase Methods
    
    func pullCardData() {
        let cardRef = ref.child("cards")
        cardRef.observe(DataEventType.value, with: { (snapshot) in
            
            for childs in snapshot.children {
                let allCardID = (childs as AnyObject).key as String
                if allCardID == self.thisCardIDTransfered {
                    let thisCardLocation = cardRef.child(self.thisCardIDTransfered)
                    
                    thisCardLocation.observe(DataEventType.value, with: { (snap) in
                        
                        
                        let thisCardDetails = snap as DataSnapshot
                        
                        
                        if let cardDict = thisCardDetails.value as? [String: AnyObject] {
                            self.nicknameTextField.text = cardDict["nickname"] as? String
                            self.digitsTextField.text = cardDict["last4"] as? String
                        }
                    })
                }
            }
        })
    }
    
    
    // MARK: Card Was Altered with Alert
    
    func changeStatusOfCardAndServices() {
        
        let alertController = UIAlertController(title: "Something went wrong!", message: "This will mark all linked services as 'needs attention.' You will have to update each service one at a time!", preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "Never Mind!", style: UIAlertActionStyle.cancel, handler: nil)
        
        let okAction = UIAlertAction(title: "I Understand!", style: UIAlertActionStyle.default) { (result: UIAlertAction) in
            
            var servicesArr: [String] = []
            let thisCard = self.ref.child("cards").child(self.thisCardIDTransfered).child("services")
            
            Analytics.logEvent("Card_Altered", parameters: ["success" : true])
            
            Answers.logCustomEvent(withName: "Card was Altered",
                                   customAttributes: nil)
            
            thisCard.observe(DataEventType.value, with: { (snapshot) in
                
                
                for services in snapshot.children {
                    let theseServiceID = (services as AnyObject).key as String
                    servicesArr.append(theseServiceID)
                }
                for each in servicesArr {
                    let servicesToChange = self.ref.child("services")
                    
                    servicesToChange.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                        
                        for services in snapshot.children {
                            let allServiceID = (services as AnyObject).key as String
                            if allServiceID == each {
                                let serviceToMark = servicesToChange.child(each)
                                serviceToMark.updateChildValues(["serviceStatus": false])
                                serviceToMark.updateChildValues(["attentionInt": 1])
                            }
                        }
                    })
                }
            })
            
            
            if let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "CardDetailVC") as? CardDetailViewController {
                detailVC.cardID = self.thisCardIDTransfered
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
            
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    
    
    
    // MARK: Delete Card with UIAlert
    
    func deleteCard() {
        
        let alertController = UIAlertController(title: "Wait!", message: "This will completely remove this card from your account. All the services linked to this card will be removed. Your total fixed monthly expenses will also be erased!", preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "Never Mind!", style: .cancel, handler: nil)
        
        
        
        
        let okAction = UIAlertAction(title: "I Understand!", style: .destructive) { (result: UIAlertAction) in
            
            let thisCard = self.ref.child("cards").child(self.thisCardIDTransfered)
            let thisCardInUsers = self.ref.child("users").child((self.user?.uid)!).child("cards").child(self.thisCardIDTransfered)

            thisCard.removeValue(completionBlock: { (error, reference) in
                if error == nil {
                    thisCardInUsers.removeValue(completionBlock: { (error2, ref2) in
                        let cardNode = self.ref.child("users").child((self.user?.uid)!).child("cards")
                        
                        cardNode.observeSingleEvent(of: .value, with: { (snapshot) in
                            
                            
                            
                            
                            if snapshot.hasChildren() {
                                //
                                DispatchQueue.main.async {
                                    if let walletVC = self.storyboard?.instantiateViewController(withIdentifier: "WalletVC") as? CardWalletViewController {
                                        self.navigationController?.pushViewController(walletVC, animated: true)
                                    }
                                    
                                }
                                
                                
                            } else {
                                DispatchQueue.main.async {
                                    
                                    if let addVC = self.storyboard?.instantiateViewController(withIdentifier: "AddCardVC") as? AddCardViewController {
                                        self.navigationController?.pushViewController(addVC, animated: true)
                                        
                                    }
                                    
                                }
                            }
                            
                        })
                        
                    })
                }
            })
            
                        Analytics.logEvent("Card_Deleted", parameters: ["success" : true])
            
                        Answers.logCustomEvent(withName: "Card Deleted",
                                              customAttributes: nil)
            
            
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
        
        
    }
    

    // MARK: Update Card
    
    func updateCard() {
        let tCardName = nicknameTextField.text ?? ""
        let tLast4 = last4Pulled ?? ""
        let tCardType = digitsTextField.text ?? ""
        let thisCard = ref.child("cards").child(thisCardIDTransfered)

        thisCard.updateChildValues(["nickname": tCardName, "last4": tLast4, "type": tCardType])
        
        
        
        if let detailVC = storyboard?.instantiateViewController(withIdentifier: "CardDetailVC") as? CardDetailViewController {
            detailVC.cardID = thisCardIDTransfered
            navigationController?.pushViewController(detailVC, animated: true)
        }
        
        
        
    }
    
    
    // MARK: IB Actions
    
    @IBAction func leftBarButtonTapped(_ sender: UIBarButtonItem) {
        leftNavBarButton.isEnabled = false
        if let detailVC = storyboard?.instantiateViewController(withIdentifier: "CardDetailVC") as? CardDetailViewController {
            detailVC.cardID = thisCardIDTransfered
            navigationController?.pushViewController(detailVC, animated: true)
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
    
    // MARK: Keyboard Methods
    
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
    
    
    func dismissKeyboard() {
        view.endEditing(true)
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
    
    
} // End of EditCardViewController Class


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
