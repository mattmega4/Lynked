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
import MBProgressHUD
import FirebaseAnalytics


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
  
  var card: Card?
  var serviceArray = [Service]()
  
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
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    leftNavBarButton.isEnabled = true
    rightNavBarButton.isEnabled = true
    populateCardInfo()
  }
  
  
  // MARK: - Update View from Firebase
  
  func populateCardInfo() {
    segControl.selectedSegmentIndex = card?.colorIndex ?? 0
    nicknameTextField.text = card?.nickname
    digitsTextField.text = card?.fourDigits
  }
  
  
  // MARK: - Card Was Altered with Alert
  
  func changeStatusOfCardAndServices() { // reset all services to needs attention
    
    let alertController = UIAlertController(title: "Wait!", message: "This will mark all linked services as 'needs attention.' You will have to update each service one at a time!", preferredStyle: UIAlertController.Style.alert)
    
    
    
    let cancelAction = UIAlertAction(title: "Never Mind!", style: UIAlertAction.Style.cancel, handler: nil)
    
    let okAction = UIAlertAction(title: "I Understand!", style: UIAlertAction.Style.default) { (result: UIAlertAction) in
      FirebaseUtility.shared.resetServices(services: self.serviceArray) { (services) in
        
        Analytics.logEvent(AnalyticsKeys.cardAltered, parameters: [AnalyticsKeys.success : true])
        
        Answers.logCustomEvent(withName: AnalyticsKeys.cardAltered,
                               customAttributes: nil)
        
        self.navigationController?.popViewController(animated: true)
      }
    }
    
    alertController.addAction(cancelAction)
    alertController.addAction(okAction)
    self.present(alertController, animated: true, completion: nil)
    
  }
  
  
  // MARK: - Delete Card with UIAlert
  
  func deleteCard() {
    
    let alertController = UIAlertController(title: "Wait!", message: "This will completely remove this card from your account. All the services linked to this card will be removed. Your total fixed monthly expenses will also be erased!", preferredStyle: UIAlertController.Style.alert)
    
    let cancelAction = UIAlertAction(title: "Never Mind!", style: .cancel, handler: nil)
    
    let okAction = UIAlertAction(title: "I Understand!", style: .destructive) { (result: UIAlertAction) in
      
      guard let theCard = self.card else {
        return
      }
      
      FirebaseUtility.shared.delete(card: theCard, completion: { (success, error) in
        if let errorMessage = error {
          print(errorMessage)
        } else if success {
          NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)

          Analytics.logEvent(AnalyticsKeys.cardDeleted, parameters: [AnalyticsKeys.success : true])
          
          Answers.logCustomEvent(withName: AnalyticsKeys.cardDeleted,
                                 customAttributes: nil)
          
          if let walletVC = self.storyboard?.instantiateViewController(withIdentifier: StoryboardKeys.walletViewControllerStoryboardID) as? WalletViewController {
            self.navigationController?.pushViewController(walletVC, animated: true)
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
    
    let color: Int = segControl.selectedSegmentIndex
    print(color)
    print("fo")
    
    FirebaseUtility.shared.update(card: theCard, nickName: nicknameTextField.text, last4: digitsTextField.text, color: color) { (updatedCard, error) in
      NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
      
      Analytics.logEvent(AnalyticsKeys.updateCard, parameters: [AnalyticsKeys.success : true])
      
      Answers.logCustomEvent(withName: AnalyticsKeys.updateCard, customAttributes: nil)
      
      
      
      self.navigationController?.popViewController(animated: true)
    }
  }
  
  
  // MARK: - IB Actions
  
  @IBAction func leftBarButtonTapped(_ sender: UIBarButtonItem) {
    leftNavBarButton.isEnabled = false
    if let detailVC = storyboard?.instantiateViewController(withIdentifier: StoryboardKeys.servicesViewControllerStoryboardID) as? ServiceListViewController {
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
  
  @objc func keyboardWillShow(notification:NSNotification) {
    let userInfo = notification.userInfo!
    var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
    keyboardFrame = self.view.convert(keyboardFrame, from: nil)
    var contentInset: UIEdgeInsets = self.scrollView.contentInset
    contentInset.bottom = keyboardFrame.size.height + 30
    self.scrollView.contentInset = contentInset
  }
  
  
  @objc func keyboardWillHide(notification:NSNotification) {
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
      
      let newLength = text.count + string.count - range.length
      return  allowedCharacters.isSuperset(of: characterSet) && newLength <= 4 // Bool
    }
    
    return true
  }
  
}




