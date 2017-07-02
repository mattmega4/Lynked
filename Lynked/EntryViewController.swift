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

class EntryViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var mainLogoImageView: UIImageView!
    
    @IBOutlet weak var leftContainerView: UIView!
    @IBOutlet weak var leftContainerButton: UIButton!
    @IBOutlet weak var leftContainerLabel: UILabel!
    @IBOutlet weak var leftContainerIndicatorImageView: UIImageView!
    
    @IBOutlet weak var rightContainerView: UIView!
    @IBOutlet weak var rightContainerButton: UIButton!
    @IBOutlet weak var rightContainerLabel: UILabel!
    @IBOutlet weak var rightContainerIndicatorImageView: UIImageView!
    
    @IBOutlet weak var bottomContainerView: UIView!
    @IBOutlet weak var textFieldOne: UITextField!
    @IBOutlet weak var textFieldTwo: UITextField!
    @IBOutlet weak var signInOrUpButtonContainerView: UIView!
    @IBOutlet weak var signInOrUpButton: UIButton!
    
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
        leftContainerLabel.alpha = 0.3
        leftContainerIndicatorImageView.image = #imageLiteral(resourceName: "indicatorTriangle")
//        leftContainerIndicatorImageView.image = UIImage.init(named: "indicatorTriangle.png")
    }
    
    
    func showLeftContainerViewContents() {
        leftContainerButton.alpha = 1.0
        leftContainerButton.isEnabled = true
        leftContainerLabel.alpha = 1.0
        leftContainerIndicatorImageView.image = nil
    }
    
    
    func hideRightContainerViewContents() {
        rightContainerButton.alpha = 0.3
        rightContainerButton.isEnabled = false
        rightContainerLabel.alpha = 0.3
        rightContainerIndicatorImageView.image = UIImage.init(named: "indicatorTriangle.png")
        rightContainerIndicatorImageView.image = #imageLiteral(resourceName: "indicatorTriangle")
    }
    
    
    func showRightContainerViewContents() {
        rightContainerButton.alpha = 1.0
        rightContainerButton.isEnabled = true
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
        checkIfBothRegisterRequirementsAreMet() // ?
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
    
    
    // MARK: - Sign User In
    
    func signUserIn() {
        FirebaseUtility.shared.signUserInWith(email: textFieldOne.text,password: textFieldTwo.text) { (user, errMessage) in
            
            if let errorMessage = errMessage {
                let alertController = UIAlertController(title: "Sorry, Something went wrong!", message: "\(errorMessage)", preferredStyle: .alert)
                self.present(alertController, animated: true, completion:nil)
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
                }
                alertController.addAction(OKAction)
            }
            else {
                if let splitVC = self.storyboard?.instantiateViewController(withIdentifier: SPLIT_STORYBOARD_IDENTIFIER) as? UISplitViewController {
                    self.present(splitVC, animated: true, completion: nil)
                }
                
            }
        }
    }
    
    
    // MARK: - Register User
    
    func registerNewUser() {
        FirebaseUtility.shared.registerUserWith(email: newUserEmail, password: textFieldOne.text, confirmPassword: textFieldTwo.text) { (user, errMessage) in
            
            if let errorMessage = errMessage {
                let alertController = UIAlertController(title: "Sorry, Something went wrong!", message: "\(errorMessage)", preferredStyle: .alert)
                self.present(alertController, animated: true, completion:nil)
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
                }
                alertController.addAction(OKAction)
            }
            else {
                if let addVC = self.storyboard?.instantiateViewController(withIdentifier: ADD_CARD_STORYBOARD_IDENTIFIER) as? AddCardViewController {
                    self.navigationController?.pushViewController(addVC, animated: true)
                }
            }
        }
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
    
    
    // MARK: - Keyboard Methods
    
    func keyboardWillShow(notification:NSNotification) {
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        var contentInset: UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 60
        self.scrollView.contentInset = contentInset
        
        hideLeftContainerViewContents()
        hideRightContainerViewContents()
        leftContainerIndicatorImageView.isHidden = true
        rightContainerIndicatorImageView.isHidden = true
    }
    
    
    func keyboardWillHide(notification:NSNotification) {
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
            }
            else {
                textFieldTwo.returnKeyType = .done
                bottomContainerStateSwitcher()
            }
        } else if leftOn == false && rightOn == true {
            if createUserStepOneFinished == false {
                if textField == textFieldOne {
                    textFieldOne.returnKeyType = .continue
                    bottomContainerStateSwitcher()
                }
            } else {
                if textField == textFieldOne {
                    textFieldOne.returnKeyType = .next
                    textFieldTwo.becomeFirstResponder()
                } else {
                    textFieldTwo.returnKeyType = .done
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
            fields.attributedPlaceholder = NSAttributedString(string: fields.placeholder!, attributes: [NSForegroundColorAttributeName : placeHolderLightColor])
        }
    }
    
    
    // MARK: - Text Field Targets
    
    func checkIfTopTextFIeldIsSatisfied(textField: UITextField) {
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
                }
                else {
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
    
    
    func checkIfBottomTextFieldIsSatisfied(textField: UITextField) {
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
