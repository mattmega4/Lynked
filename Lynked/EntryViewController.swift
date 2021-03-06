//
//  EntryViewController.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 5/10/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import Fabric
import Crashlytics
import LocalAuthentication
import FirebaseAnalytics
import FirebasePerformance



class EntryViewController: UIViewController {
  
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var contentView: UIView!
  
  @IBOutlet weak var topContainerView: UIView!
  @IBOutlet weak var mainLogoImageView: UIImageView!
  
  @IBOutlet weak var leftContainerView: UIView!
  @IBOutlet weak var leftContainerButton: UIButton!
  @IBOutlet weak var leftImageView: UIImageView!
  @IBOutlet weak var leftContainerLabel: UILabel!
  @IBOutlet weak var leftContainerIndicatorImageView: UIImageView!
  
  @IBOutlet weak var rightContainerView: UIView!
  @IBOutlet weak var rightContainerButton: UIButton!
  @IBOutlet weak var rightImageView: UIImageView!
  @IBOutlet weak var rightContainerLabel: UILabel!
  @IBOutlet weak var rightContainerIndicatorImageView: UIImageView!
  
  @IBOutlet weak var bottomContainerView: UIView!
  @IBOutlet weak var textFieldOne: UITextField!
  @IBOutlet weak var textFieldTwo: UITextField!
  @IBOutlet weak var signInOrUpButtonContainerView: UIView!
  @IBOutlet weak var signInOrUpButton: UIButton!
  @IBOutlet weak var resetPasswordButton: UIButton!
  
  var leftOn: Bool?
  var rightOn: Bool?
  
  var topFieldIsSatisfied = false
  var bottomFieldIsSatisfied = false
  var nextButtonRequirementsHaveBeenMet = false
  
  var userStateIsOnSignIn: Bool?
  var createUserStepOneFinished: Bool?
  
  var newUserEmail: String?
  var newUserPassword: String?
  
  var tempUID: String?
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    textFieldOne.delegate = self
    textFieldTwo.delegate = self
    
    self.navigationController?.isNavigationBarHidden = true
    bottomTextFieldDelegateAndAutoCorrectAndPlaceholderColorSetup()
    textFieldOne.addTarget(self, action: #selector(checkIfTopTextFIeldIsSatisfied(textField:)), for: .editingChanged)
    textFieldTwo.addTarget(self, action: #selector(checkIfBottomTextFieldIsSatisfied(textField:)), for: .editingChanged)
    
    // testing 123
    
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EntryViewController.dismissKeyboard))
     view.addGestureRecognizer(tap)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
  }
  
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    checkIfBothSignInRequirementsAreMet()
    leftButtonWasTappedWhichIsDefault()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if Auth.auth().currentUser != nil {
      useTouchID()
    }
  }
  
  
  // MARK: - Switch Logic For Sign In or Create Button in Bottom Container View
  
  func bottomContainerStateSwitcher() {
    if userStateIsOnSignIn == true {
      signUserIn()
    } else if userStateIsOnSignIn == false && createUserStepOneFinished == false {
      newUserEmail = textFieldOne.text ?? ""
      continueTappedAfterStageOneRegisterAccountActive()
    } else if userStateIsOnSignIn == false && createUserStepOneFinished == true {
      registerNewUser()
    }
  }
  
  
  // MARK: - Hide and Show Left and Right Container View Contents
  
  func hideLeftContainerViewContents() {
    leftContainerButton.alpha = 0.3
    leftContainerButton.isEnabled = false
    leftImageView.alpha = 0.5
    leftContainerLabel.alpha = 0.5
    leftContainerIndicatorImageView.image = #imageLiteral(resourceName: "indicatorTriangle")
  }
  
  
  func showLeftContainerViewContents() {
    leftContainerButton.alpha = 1.0
    leftContainerButton.isEnabled = true
    leftImageView.alpha = 1.0
    leftContainerLabel.alpha = 1.0
    leftContainerIndicatorImageView.image = nil
  }
  
  
  func hideRightContainerViewContents() {
    rightContainerButton.alpha = 0.3
    rightContainerButton.isEnabled = false
    rightImageView.alpha = 0.5
    rightContainerLabel.alpha = 0.5
    rightContainerIndicatorImageView.image = UIImage.init(named: "indicatorTriangle.png")
    rightContainerIndicatorImageView.image = #imageLiteral(resourceName: "indicatorTriangle")
  }
  
  
  func showRightContainerViewContents() {
    rightContainerButton.alpha = 1.0
    rightContainerButton.isEnabled = true
    rightImageView.alpha = 1.0
    rightContainerLabel.alpha = 1.0
    rightContainerIndicatorImageView.image = nil
  }
  
  
  // MARK: - Keyboard Show Logic
  
  func hideShowKeyboardLogicLeftVsRight() {
    if leftOn == true && rightOn == false {
      showRightContainerViewContents()
    } else if leftOn == false && rightOn == true {
      showLeftContainerViewContents()
    }
  }
  
  
  // MARK: - Reset Text Fields
  
  func resetTextFieldText() {
    textFieldOne.text = ""
    textFieldTwo.text = ""
  }
  
  
  // MARK: - Reset Requirements
  
  func resetLoginRequirements() {
    createUserStepOneFinished = false
    userStateIsOnSignIn = true
    topFieldIsSatisfied = false
    bottomFieldIsSatisfied = false
    nextButtonRequirementsHaveBeenMet = false
  }
  
  
  func resetRegisterRequirementsForStageOne() {
    userStateIsOnSignIn = false
    topFieldIsSatisfied = false
    bottomFieldIsSatisfied = false
    nextButtonRequirementsHaveBeenMet = false
  }
  
  
  func resetRegisterRequirementsForStageTwo() {
    createUserStepOneFinished = true
    userStateIsOnSignIn = false
    topFieldIsSatisfied = false
    bottomFieldIsSatisfied = false
    nextButtonRequirementsHaveBeenMet = false
    textFieldTwo.isHidden = false
    textFieldTwo.isEnabled = true
  }
  
  
  // MARK: - Login TextField Details
  
  func setupLoginTextFields() {
    textFieldTwo.isHidden = false
    textFieldTwo.isEnabled = true
    textFieldOne.placeholder = "Enter Email"
    textFieldTwo.placeholder = "Enter Password"
    textFieldOne.keyboardType = .emailAddress
    textFieldTwo.keyboardType = .default
    textFieldOne.isSecureTextEntry = false
    textFieldTwo.isSecureTextEntry = true
  }
  
  
  func setupRegisterTextFieldsForStageOne() {
    textFieldOne.text = ""
    textFieldTwo.text = ""
    textFieldTwo.isHidden = true
    textFieldTwo.isEnabled = false
    textFieldOne.placeholder = "Enter Email"
    textFieldOne.keyboardType = .emailAddress
    textFieldOne.isSecureTextEntry = false
    textFieldTwo.isSecureTextEntry = true
  }
  
  
  func setupRegisterTextFieldsForStageTwo() {
    textFieldOne.text = ""
    textFieldTwo.text = ""
    textFieldOne.placeholder = "Enter Password"
    textFieldTwo.placeholder = "Confirm Password"
    textFieldOne.keyboardType = .default
    textFieldTwo.keyboardType = .default
    textFieldOne.isSecureTextEntry = true
    textFieldTwo.isSecureTextEntry = true
  }
  
  
  // MARK: - Logic For State Switching
  
  func leftButtonWasTappedWhichIsDefault() {
    leftOn = true
    rightOn = false
    hideLeftContainerViewContents()
    showRightContainerViewContents()
    resetTextFieldText()
    resetLoginRequirements()
    setupLoginTextFields()
    signInOrUpButton.setTitle("SIGN IN", for: UIControlState())
  }
  
  
  func rightButtonWasTapped() {
    leftOn = false
    rightOn = true
    resetTextFieldText()
    showLeftContainerViewContents()
    hideRightContainerViewContents()
    resetRegisterRequirementsForStageOne()
    checkIfBothRegisterRequirementsAreMet()
    setupRegisterTextFieldsForStageOne()
    signInOrUpButton.setTitle("CONTINUE", for: UIControlState())
  }
  
  
  func continueTappedAfterStageOneRegisterAccountActive() {
    leftOn = false
    rightOn = true
    resetRegisterRequirementsForStageTwo()
    checkIfBothRegisterRequirementsAreMet()
    setupRegisterTextFieldsForStageTwo()
    signInOrUpButton.setTitle("CREATE ACCOUNT", for: UIControlState())
  }
  
  
  // MARK: - Continue Condition Checking Logic
  
  func checkIfBothSignInRequirementsAreMet() {
    if topFieldIsSatisfied == true && bottomFieldIsSatisfied == true {
      signInOrUpButton.isEnabled = true
      signInOrUpButton.isHidden = false
      signInOrUpButtonContainerView.isHidden = false
    } else {
      signInOrUpButton.isEnabled = false
      signInOrUpButton.isHidden = true
      signInOrUpButtonContainerView.isHidden = true
    }
  }
  
  
  func checkIfTopContinueRequirementIsMet() {
    if topFieldIsSatisfied == true {
      signInOrUpButton.isEnabled = true
      signInOrUpButton.isHidden = false
      signInOrUpButtonContainerView.isHidden = false
    } else {
      signInOrUpButton.isEnabled = false
      signInOrUpButton.isHidden = true
      signInOrUpButtonContainerView.isHidden = true
    }
  }
  
  
  func checkIfBothRegisterRequirementsAreMet() {
    if textFieldOne.text == textFieldTwo.text {
      signInOrUpButton.isEnabled = true
      signInOrUpButton.isHidden = false
      signInOrUpButtonContainerView.isHidden = false
      
    } else {
      signInOrUpButton.isEnabled = false
      signInOrUpButton.isHidden = true
      signInOrUpButtonContainerView.isHidden = true
    }
  }
  
  
  // MARK: - Local Authorization // spell check
  
  func useTouchID() {
    
    let context = LAContext()
    var error: NSError?
    
    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
      // can eval
      let reason = "Use Touch ID to Log In"
      context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply: { (success, authError) in
        
        DispatchQueue.main.async {
          if success {
            self.dismiss(animated: true, completion: nil)
          }
        }
      })
    }
  }
  
  
  // MARK: - Sign User In
  
  func signUserIn() {
    FirebaseUtility.shared.signUserInWith(email: textFieldOne.text,password: textFieldTwo.text) { (user, errMessage) in
      
      if let errorMessage = errMessage {
        let alertController = UIAlertController(title: "Sorry, Something went wrong!", message: "\(errorMessage)", preferredStyle: .alert)
        self.present(alertController, animated: true, completion:nil)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
        }
        alertController.addAction(OKAction)
      } else {
        
        Analytics.logEvent(AnalyticsKeys.emailLogin, parameters: [AnalyticsKeys.success : true])
        Answers.logLogin(withMethod: AnalyticsKeys.emailLogin,
                         success: true,
                         customAttributes: [:])
        self.dismiss(animated: true, completion: nil)
      }
    }
  }
  
  
  // MARK: - Register User
  
  func registerNewUser() {
    FirebaseUtility.shared.registerUserWith(email: newUserEmail, password: textFieldOne.text, confirmPassword: textFieldTwo.text) { (user, errMessage) in
      
      if let errorMessage = errMessage {
        let alertController = UIAlertController(title: "Sorry, Something went wrong!", message: "\(errorMessage)", preferredStyle: .alert)
        self.present(alertController, animated: true, completion:nil)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction) in
          self.rightButtonWasTapped()
        }
        alertController.addAction(OKAction)
      } else {
        
        Analytics.logEvent(AnalyticsKeys.emailRegister, parameters: [AnalyticsKeys.success : true])
        Answers.logSignUp(withMethod: AnalyticsKeys.emailRegister,
                          success: true,
                          customAttributes: [:])
        
        self.dismiss(animated: true, completion: nil)
      }
    }
  }
  
  // MARK: - Reset Password
  
  func resetPassword() {
    
    let alertController = UIAlertController(title: "Reset Password?", message: "An email will be sent to the entered email address with a link to reset password", preferredStyle: UIAlertControllerStyle.alert)
    
    alertController.addTextField { (textField) in
      textField.placeholder = "Email"
      textField.keyboardAppearance = .dark
      textField.keyboardType = .emailAddress
    }
    
    
    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
    
    let okAction = UIAlertAction(title: "Reset", style: UIAlertActionStyle.destructive) { (result: UIAlertAction) in
      
      if let txt = alertController.textFields?.first?.text {
        FirebaseUtility.shared.resetPasswordWith(email: txt, completion: { (result) in
          self.leftButtonWasTappedWhichIsDefault()
        })
      }
    }
    
    alertController.addAction(cancelAction)
    alertController.addAction(okAction)
    self.present(alertController, animated: true, completion: nil)
    
  }
  
  
  // MARK: - IB Actions
  
  @IBAction func leftContainerButtonTapped(_ sender: UIButton) {
    leftButtonWasTappedWhichIsDefault()
  }
  
  @IBAction func rightContainerButtonTapped(_ sender: UIButton) {
    rightButtonWasTapped()
  }
  
  @IBAction func signInOrUpButtonTapped(_ sender: UIButton) {
    bottomContainerStateSwitcher()
  }
  
  @IBAction func resetPasswordButtonTapped(_ sender: UIButton) {
    resetPassword()
  }
  
  // MARK: - Keyboard Methods
  
  @objc func keyboardWillShow(notification:NSNotification) {
    var userInfo = notification.userInfo!
    var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
    keyboardFrame = self.view.convert(keyboardFrame, from: nil)
    var contentInset: UIEdgeInsets = self.scrollView.contentInset
    contentInset.bottom = keyboardFrame.size.height + 100
    self.scrollView.contentInset = contentInset
    
    hideLeftContainerViewContents()
    hideRightContainerViewContents()
    leftContainerIndicatorImageView.isHidden = true
    rightContainerIndicatorImageView.isHidden = true
  }
  
  
  @objc func keyboardWillHide(notification:NSNotification) {
    let contentInset:UIEdgeInsets = UIEdgeInsets.zero
    self.scrollView.contentInset = contentInset
    
    leftContainerIndicatorImageView.isHidden = false
    rightContainerIndicatorImageView.isHidden = false
    hideShowKeyboardLogicLeftVsRight()
  }
  
  
} // MARK: - End of EntryViewController

extension EntryViewController: UITextFieldDelegate {
  
  func textFieldShouldClear(_ textField: UITextField) -> Bool {
    self.view.endEditing(true)
    return false
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if leftOn == true && rightOn == false {
      if textField == textFieldOne {
        textFieldOne.returnKeyType = .next
        textFieldTwo.becomeFirstResponder()
      } else {
        textFieldTwo.returnKeyType = .done
        bottomContainerStateSwitcher()
      }
    } else if leftOn == false && rightOn == true {
      if createUserStepOneFinished == false {
        if textField == textFieldOne {
          textFieldOne.returnKeyType = .continue
          textFieldOne.keyboardType = .emailAddress
          bottomContainerStateSwitcher()
        }
      } else {
        if textField == textFieldOne {
          textFieldOne.returnKeyType = .next
          textFieldOne.keyboardType = .default
          textFieldTwo.becomeFirstResponder()
        } else {
          textFieldTwo.returnKeyType = .done
          textFieldTwo.keyboardType = .default
          bottomContainerStateSwitcher()
        }
      }
    }
    return false
  }
  
  
  // MARK: - Add Delegate, Remove AutoCorrect, and Placeholder Color to Bottom TextFields
  
  func bottomTextFieldDelegateAndAutoCorrectAndPlaceholderColorSetup() {
    var bottomTextFields: [UITextField] = []
    bottomTextFields+=[self.textFieldOne, textFieldTwo]
    let placeHolderLightColor = UIColor.lightText
    for fields in bottomTextFields {
      fields.autocorrectionType = .no
      fields.delegate = self
      fields.attributedPlaceholder = NSAttributedString(string: fields.placeholder!, attributes: [NSAttributedStringKey.foregroundColor : placeHolderLightColor])
    }
  }
  
  
  // MARK: - Text Field Targets
  
  @objc func checkIfTopTextFIeldIsSatisfied(textField: UITextField) {
    if textField == self.textFieldOne {
      if self.leftOn == true && self.rightOn == false {
        if textField.text?.validateEmail() == true {
          self.topFieldIsSatisfied = true
        } else {
          self.topFieldIsSatisfied = false
        }
        checkIfBothSignInRequirementsAreMet()
      } else if self.leftOn == false && self.rightOn == true {
        if self.createUserStepOneFinished == true {
          if textField.text?.validateEmail() == true {
            self.topFieldIsSatisfied = true
          } else {
            self.topFieldIsSatisfied = false
          }
          checkIfTopContinueRequirementIsMet()
        } else if self.createUserStepOneFinished == false {
          if textField.text?.validateEmail() == true {
            self.topFieldIsSatisfied = true
          } else {
            self.topFieldIsSatisfied = false
          }
          checkIfTopContinueRequirementIsMet()
        } else {
          if textField.text?.isEmpty == true {
            self.topFieldIsSatisfied = false
          } else {
            self.topFieldIsSatisfied = true
          }
          checkIfBothRegisterRequirementsAreMet()
        }
      }
    }
  }
  
  
  @objc func checkIfBottomTextFieldIsSatisfied(textField: UITextField) {
    if textField == self.textFieldTwo {
      if self.leftOn == true && self.rightOn == false {
        if textField.text?.isEmpty == true {
          self.bottomFieldIsSatisfied = false
        } else {
          self.bottomFieldIsSatisfied = true
        }
        checkIfBothSignInRequirementsAreMet()
      } else if self.leftOn == false && self.rightOn == true {
        if textField.text?.isEmpty == true {
          self.bottomFieldIsSatisfied = false
        } else {
          self.bottomFieldIsSatisfied = true
        }
        checkIfBothRegisterRequirementsAreMet()
      }
    }
  }
  
  
}





