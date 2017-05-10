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
  @IBOutlet weak var typeLabel: UILabel!
  @IBOutlet weak var alteredButton: UIButton!
  @IBOutlet weak var deleteButton: UIButton!
  @IBOutlet weak var nicknameTextField: UITextField!
  @IBOutlet weak var typeTextField: UITextField!
  
  var cardStatus: Bool?
  var nicknameFieldSatisfied: Bool?
  var typeFieldSatisfied: Bool?
  var thisCardIDTransfered = ""
  var serviceToDelete: [String] = []
  let ref = FIRDatabase.database().reference()
  let user = FIRAuth.auth()?.currentUser
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.nicknameTextField.delegate = self
    self.typeTextField.delegate = self
    
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
    title = "Edit Card"
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
  
  
  // MARK: Firebase Methods
  
  func pullCardData() {
    let cardRef = ref.child("cards")
    cardRef.observeSingleEvent(of: .value, with: { snapshot in
      for childs in snapshot.children {
        let allCardID = (childs as AnyObject).key as String
        if allCardID == self.thisCardIDTransfered {
          let thisCardLocation = cardRef.child(self.thisCardIDTransfered)
          thisCardLocation.observeSingleEvent(of: .value, with: {snap in
            let thisCardDetails = snap as FIRDataSnapshot
            let cardDict = thisCardDetails.value as! [String: AnyObject]
            //            if cardDict["cardStatus"] as! Bool == true {
            //              self.cardStatus = true
            //              self.cardStatusImageView.image = UIImage.init(named: "greenCheck.png")
            //            } else {
            //              self.cardStatus = false
            //              self.cardStatusImageView.image = UIImage.init(named: "redEx.png")
            //            }
            self.nicknameTextField.text = cardDict["nickname"] as? String
            self.typeTextField.text = cardDict["type"] as? String
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
      thisCard.observeSingleEvent(of: .value, with: { snapshot in
        for services in snapshot.children {
          let theseServiceID = (services as AnyObject).key as String
          servicesArr.append(theseServiceID)
        }
        for each in servicesArr {
          let servicesToChange = self.ref.child("services")
          servicesToChange.observeSingleEvent(of: .value, with: { snapshot in
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
      
      let card = self.ref.child("cards").child(self.thisCardIDTransfered)
      card.updateChildValues(["cardStatus": false])
      self.dismiss(animated: true, completion: nil)
      
    }
    
    alertController.addAction(cancelAction)
    alertController.addAction(okAction)
    
    self.present(alertController, animated: true, completion: nil)
    
  }
  
  
  // MARK: Delete Card with UIAlert
  
  func deleteCard() {
    
    let alertController = UIAlertController(title: "Wait!", message: "This will completely remove this card from your account. All the services linked to this card will be removed. Your total fixed monthly expenses will also be erased!", preferredStyle: UIAlertControllerStyle.alert)
    
    let cancelAction = UIAlertAction(title: "Never Mind!", style: UIAlertActionStyle.cancel, handler: nil)
    
    let okAction = UIAlertAction(title: "I Understand!", style: UIAlertActionStyle.default) { (result: UIAlertAction) in
      
      let thisCard = self.ref.child("cards").child(self.thisCardIDTransfered)
      thisCard.removeValue()
      let thisCardInUsers = self.ref.child("users").child((self.user?.uid)!).child("cards").child(self.thisCardIDTransfered)
      thisCardInUsers.removeValue()
      self.performSegue(withIdentifier: "fromEditCardToLandingPage", sender: self)
      
    }
    
    alertController.addAction(cancelAction)
    alertController.addAction(okAction)
    
    self.present(alertController, animated: true, completion: nil)
    
  }
  
  
  // MARK: Update Card
  
  func updateCard() {
    let tCardName = nicknameTextField.text ?? ""
    let tCardType = typeTextField.text ?? ""
    let thisCard = ref.child("cards").child(thisCardIDTransfered)
    thisCard.updateChildValues(["nickname": tCardName, "type": tCardType, "cardStatus": true])
    delay(1.5) {
      self.dismiss(animated: true, completion: nil)
    }
  }
  
  
  // MARK: IB Actions
  
  @IBAction func leftBarButtonTapped(_ sender: UIBarButtonItem) {
    leftNavBarButton.isEnabled = false
    dismiss(animated: true, completion: nil)
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
  //
}
