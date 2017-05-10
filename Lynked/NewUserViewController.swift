//
//  NewUserViewController.swift
//  Lynked
//
//  Created by Matthew Singleton on 12/27/16.
//  Copyright © 2016 Matthew Singleton. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class NewUserViewController: UIViewController {
  
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var navBarCancelButton: UIBarButtonItem!
  
  @IBOutlet weak var mainLogo: UIImageView!
  @IBOutlet weak var mainTitle: UILabel!
  
  @IBOutlet weak var firstDividerView: UIView!
  @IBOutlet weak var secondDividerView: UIView!
  @IBOutlet weak var thirdDividerView: UIView!
  @IBOutlet weak var fourthDividerView: UIView!
  
  @IBOutlet weak var firstContainerView: UIView!
  @IBOutlet weak var secondContainerView: UIView!
  @IBOutlet weak var thirdContainerView: UIView!
  @IBOutlet weak var bottomButtonContainerView: UIView!
  
  @IBOutlet weak var firstContainerLabel: UILabel!
  @IBOutlet weak var secondContainerLabel: UILabel!
  @IBOutlet weak var thirdContainerLabel: UILabel!
  
  @IBOutlet weak var firstContainerTextField: UITextField!
  @IBOutlet weak var secondContainerTextField: UITextField!
  @IBOutlet weak var thirdContainerTextField: UITextField!
  
  @IBOutlet weak var firstContainerIndicatorImageView: UIImageView!
  
  @IBOutlet weak var bottomButton: UIButton!
  
  let ref = FIRDatabase.database().reference()
  
  var emailIsSatisfied = false
  var passwordsAreSatisfied = false
  var tempUID = ""
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setNavBar()
    populateArraysAndAddTargets()
    
    self.firstContainerTextField.delegate = self
    self.secondContainerTextField.delegate = self
    self.thirdContainerTextField.delegate = self
    
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(NewUserViewController.dismissKeyboard))
    view.addGestureRecognizer(tap)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
  }
  
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    checkToEnableSignUpButtonIfConditionsAreMet()
  }
  
  
  // MARK: Nav Bar & View Design
  
  func setNavBar() {
    title = "New User"
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
  
  
  // MARK: Populate Arrays and Add Targets
  
  func populateArraysAndAddTargets() {
    firstContainerTextField.addTarget(self, action: #selector(checkIfEmailTextFieldIsSatisfied(textField:)), for: .editingChanged)
    secondContainerTextField.addTarget(self, action: #selector(checkIfPasswordTextFieldsAreSatisfied), for: .editingChanged)
    thirdContainerTextField.addTarget(self, action: #selector(checkIfPasswordTextFieldsAreSatisfied), for: .editingChanged)
  }
  
  
  // MARK: Firebase Sign Up
  
  func signUserUp() {
    let email = firstContainerTextField.text ?? ""
    
    let topPassword = secondContainerTextField.text ?? ""
    let bottomPassword = thirdContainerTextField.text ?? ""
    
    if topPassword == bottomPassword {
      let password = topPassword
      FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
        var errMessage = ""
        if (error != nil) {
          if let errCode = FIRAuthErrorCode(rawValue: (error?._code)!) {
            switch errCode {
            case .errorCodeInvalidEmail:
              errMessage = "The entered email does not meet requirements."
            case .errorCodeEmailAlreadyInUse:
              errMessage = "The entered email has already been registered."
            case .errorCodeWeakPassword:
              errMessage = "The entered password does not meet minimum requirements."
            default:
              errMessage = "Please try again."
            }
          }
          let alertController = UIAlertController(title: "Sorry, Something went wrong!", message: "\(errMessage)", preferredStyle: .alert)
          self.present(alertController, animated: true, completion:nil)
          let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
          }
          alertController.addAction(OKAction)
        } else {
          self.ref.child("users").child((user?.uid)!).child("cards").setValue(true)
          FIRAuth.auth()!.signIn(withEmail: email,
                                 password: password)
          self.tempUID = (user?.uid)!
          self.performSegue(withIdentifier: "fromNewUserToAddCard", sender: self)
        }
      })
    }
  }
  
  
  // MARK: Enable Sign Up Button
  
  func checkToEnableSignUpButtonIfConditionsAreMet() {
    if emailIsSatisfied == true
      && passwordsAreSatisfied == true {
      bottomButtonContainerView.isHidden = false
      bottomButton.isHidden = false
      bottomButton.isEnabled = true
    } else {
      bottomButtonContainerView.isHidden = true
      bottomButton.isHidden = true
      bottomButton.isEnabled = false
    }
  }
  
  
  // MARK: IB Actions
  
  @IBAction func navBarCancelButtonTapped(_ sender: UIBarButtonItem) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func bottomButtonTapped(_ sender: UIButton) {
    signUserUp()
    bottomButton.isEnabled = false
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
  
  
} // End of NewUserViewController Class


// MARK: Text Field

extension NewUserViewController: UITextFieldDelegate {
  
  // MARK: Check if Email is Satisfied
  
  func checkIfEmailTextFieldIsSatisfied(textField: UITextField) {
    if textField == firstContainerTextField {
      if (textField.text?.isEmpty)! {
        self.emailIsSatisfied = false
      } else if textField.text?.validateEmail() == false {
        self.emailIsSatisfied = false
      } else if textField.text?.validateEmail() == true {
        self.emailIsSatisfied = true
      }
    }
    checkToEnableSignUpButtonIfConditionsAreMet()
  }
  
  
  // MARK: Check if Password is Satisfied
  
  func checkIfPasswordTextFieldsAreSatisfied() {
    
    if (!(secondContainerTextField.text?.isEmpty)! && !(thirdContainerTextField.text?.isEmpty)!) && (secondContainerTextField.text == thirdContainerTextField.text) {
      passwordsAreSatisfied = true
    } else {
      passwordsAreSatisfied = false
    }
    checkToEnableSignUpButtonIfConditionsAreMet()
  }
  
  
}
