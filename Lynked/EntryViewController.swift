//
//  EntryViewController.swift
//  Lynked
//
//  Created by Matthew Singleton on 12/17/16.
//  Copyright © 2016 Matthew Singleton. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase


class EntryViewController: UIViewController {
  
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var mainImage: UIImageView!
  @IBOutlet weak var mainTitle: UILabel!
  
  @IBOutlet weak var firstDividerView: UIView!
  @IBOutlet weak var secondDividerView: UIView!
  @IBOutlet weak var thirdDividerView: UIView!
  
  @IBOutlet weak var firstContainerView: UIView!
  @IBOutlet weak var secondContainerView: UIView!
  @IBOutlet weak var bigBottomButtonContainer: UIView!
  
  @IBOutlet weak var firstContainerLabel: UILabel!
  @IBOutlet weak var secondContainerLabel: UILabel!
  
  @IBOutlet weak var firstContainerTextField: UITextField!
  @IBOutlet weak var secondContainerTextField: UITextField!
  
  @IBOutlet weak var signUpButtton: UIButton!
  @IBOutlet weak var bigBottomButton: UIButton!
  @IBOutlet weak var forgotPasswordButton: UIButton!
  
  var emailFieldSatisfied = false
  var passwordFieldSatisfied = false
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Lynked"
    firstContainerTextField.addTarget(self, action: #selector(checkIfEmailFitsFormat(textField:)), for: .editingChanged)
    secondContainerTextField.addTarget(self, action: #selector(checkIfPasswordIsSatisfied(textField:)), for: .editingChanged)
    
    self.firstContainerTextField.delegate = self
    self.secondContainerTextField.delegate = self
    
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EntryViewController.dismissKeyboard))
    view.addGestureRecognizer(tap)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    resetPage()
  }
  
  
  // MARK: Reset
  
  func resetPage() {
    firstContainerTextField.text = ""
    secondContainerTextField.text = ""
    emailFieldSatisfied = false
    passwordFieldSatisfied = false
    checkIfAllConditionsAreMet()
  }
  
  
  // MARK: Firebase Email Login
  
  func signUserIn() {
    
    let email = firstContainerTextField.text ?? ""
    let password = secondContainerTextField.text ?? ""
    
    FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
      let ref = FIRDatabase.database().reference()
      let user = FIRAuth.auth()?.currentUser
      if error == nil {
        ref.child("users").child((user?.uid)!).child("cards")
          .observe(.value, with: { snapshot in
            if (snapshot.hasChildren()) {
              self.performSegue(withIdentifier: "fromEntryToLandingPage", sender: self)
            } else {
              self.performSegue(withIdentifier: "fromEntryToAddCard", sender: self)
            }
          })
      } else {
        let alertController = UIAlertController(title: "Something went wrong!", message: "Please check your email and/or password to be sure you typed it correctly", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "I Understand", style: UIAlertActionStyle.default) { (result: UIAlertAction) in
          print("OK")
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
        self.firstContainerTextField.text = ""
        self.secondContainerTextField.text = ""
        self.emailFieldSatisfied = false
        self.passwordFieldSatisfied = false
      }
    })
  }
  
  
  func checkIfAllConditionsAreMet() {
    if emailFieldSatisfied == true && passwordFieldSatisfied == true {
      bigBottomButtonContainer.isHidden = false
      bigBottomButton.isEnabled = true
      bigBottomButton.isHidden = false
    } else {
      bigBottomButtonContainer.isHidden = true
      bigBottomButton.isEnabled = false
      bigBottomButton.isHidden = true
    }
  }
  
  
  // MARK: IB Actions
  
  
  @IBAction func signUpButtonTapped(_ sender: UIButton) {
    performSegue(withIdentifier: "fromEntryToNewUser", sender: self)
  }
  
  @IBAction func bottomButtonTapped(_ sender: UIButton) {
    signUserIn()
    bigBottomButton.isEnabled = false
  }
  
  @IBAction func resetPasswordBottomButtonTapped(_ sender: UIButton) {
    //    resetPasswordUIAlertController()
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
  
  
} // End of EntryViewController Class


// MARK: UITextField

extension EntryViewController: UITextFieldDelegate {
  
  func checkIfEmailFitsFormat(textField: UITextField) {
    if textField == firstContainerTextField {
      if (textField.text?.isEmpty)! {
        self.emailFieldSatisfied = false
      } else if !(textField.text?.isEmpty)! && textField.text?.validateEmail() == false {
        self.emailFieldSatisfied = false
      } else if textField.text?.validateEmail() == true {
        self.emailFieldSatisfied = true
      }
    }
    checkIfAllConditionsAreMet()
  }
  
  
  func checkIfPasswordIsSatisfied(textField: UITextField) {
    if textField == secondContainerTextField {
      if (textField.text?.isEmpty)! {
        passwordFieldSatisfied = false
      } else {
        passwordFieldSatisfied = true
      }
    }
    checkIfAllConditionsAreMet()
  }
  
  
  
}
