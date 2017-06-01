//
//  LoginViewController.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 5/10/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var mainLogoImageView: UIImageView!
    @IBOutlet weak var questionMarkButton: UIButton!
    
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
    
    var topFieldIsSatisfied: Bool?
    var bottomFieldIsSatisfied: Bool?
    var nextButtonRequirementsHaveBeenMet: Bool?
    
    var userStateIsOnSignIn: Bool?
    var createUserStepOneFinished: Bool?
    
    var newUserEmail: String?
    var newUserPassword: String?
    
    let ref = Database.database().reference()
    var tempUID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bottomTextFieldDelegateAndAutoCorrectAndPlaceholderColorSetup()
        addTextFieldTargets()
        keyboardMethods()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkIfBothSignInRequirementsAreMet()
        leftButtonWasTappedWhichIsDefault()
    }
    
    
    // MARK: Add Keyboard Targets
    
    func keyboardMethods() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    // MARK: Add TextField Targets
    
    func addTextFieldTargets() {
        textFieldOne.addTarget(self, action: #selector(checkIfTopTextFIeldIsSatisfied(textField:)), for: .editingChanged)
        textFieldTwo.addTarget(self, action: #selector(checkIfBottomTextFieldIsSatisfied(textField:)), for: .editingChanged)
    }
    
    
    // MARK: Switch Logic For Sign In or Create Button in Bottom Container View
    
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
    
    
    // MARK: Hide and Show Left and Right Container View Contents
    
    func hideLeftContainerViewContents() {
        leftContainerButton.alpha = 0.3
        leftContainerButton.isEnabled = false
        leftContainerLabel.alpha = 0.3
        leftContainerIndicatorImageView.image = UIImage.init(named: "indicatorTriangle.png")
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
    }
    
    
    func showRightContainerViewContents() {
        rightContainerButton.alpha = 1.0
        rightContainerButton.isEnabled = true
        rightContainerLabel.alpha = 1.0
        rightContainerIndicatorImageView.image = nil
    }
    
    
    // MARK: Keyboard Show Logic
    
    func hideShowKeyboardLogicLeftVsRight() {
        if leftOn == true && rightOn == false {
            showRightContainerViewContents()
        } else if leftOn == false && rightOn == true {
            showLeftContainerViewContents()
        }
    }
    
    
    // MARK: Reset Text Fields
    
    func resetTextFieldText() {
        textFieldOne.text = ""
        textFieldTwo.text = ""
    }
    
    
    // MARK: Reset Requirements
    
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
    
    
    // MARK: Login TextField Details
    
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
    
    
    // MARK: Logic For State Switching
    
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
        showLeftContainerViewContents()
        hideRightContainerViewContents()
        resetTextFieldText()
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
    
    
    // MARK: Continue Condition Checking Logic
    
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
        if topFieldIsSatisfied == true && bottomFieldIsSatisfied == true && textFieldOne.text == textFieldTwo.text {
            signInOrUpButton.isEnabled = true
            signInOrUpButton.isHidden = false
            signInOrUpButtonContainerView.isHidden = false
        } else {
            signInOrUpButton.isEnabled = false
            signInOrUpButton.isHidden = true
            signInOrUpButtonContainerView.isHidden = true
        }
    }
    
    
    // MARK: Sign In
    
    func signUserIn() {
        
        let email = textFieldOne.text ?? ""
        let password = textFieldTwo.text ?? ""
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            let ref = Database.database().reference()
            let user = Auth.auth().currentUser
            if error == nil {
                ref.child("users").child((user?.uid)!).child("cards")
                    .observe(.value, with: { snapshot in
                        if (snapshot.hasChildren()) {
                            self.performSegue(withIdentifier: "fromEntryToWallet", sender: self)
                        } else {
                            self.performSegue(withIdentifier: "fromEntryToAddCard", sender: self)
                        }
                    })
                
            } else {
                
                var errMessage = ""
                
                if let errCode = AuthErrorCode(rawValue: (error?._code)!) {
                    switch errCode {
                        
                    case .invalidEmail:
                        errMessage = "The entered email does not meet requirements."
                    case .weakPassword:
                        errMessage = "The entered password does not meet minimum requirements."
                    case .wrongPassword:
                        errMessage = "The entered password is not correct."
                    default:
                        errMessage = "Please try again."
                    }
                    
                    let alertController = UIAlertController(title: "Sorry, Something went wrong!", message: "\(errMessage)", preferredStyle: .alert)
                    self.present(alertController, animated: true, completion:nil)
                    let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
                    }
                    alertController.addAction(OKAction)
                    
                }
                
                
                
                
                self.textFieldOne.text = ""
                self.textFieldTwo.text = ""
                self.topFieldIsSatisfied = false
                self.bottomFieldIsSatisfied = false
            }
        })
    }
    
    
    
    
    // TODO: Register User
    
    func registerNewUser() {
        
        if textFieldOne.text == textFieldTwo.text {
            newUserPassword = textFieldTwo.text ?? ""
            Auth.auth().createUser(withEmail: newUserEmail!, password: newUserPassword!, completion: { (user, error) in
                var errMessage = ""
                if (error != nil) {
                    if let errCode = AuthErrorCode(rawValue: (error?._code)!) {
                        switch errCode {
                            
                            
                            
                        case .invalidEmail:
                            errMessage = "The entered email does not meet requirements."
                        case .emailAlreadyInUse:
                            errMessage = "The entered email has already been registered."
                        case .weakPassword:
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
                    Auth.auth().signIn(withEmail: self.newUserEmail!, password: self.newUserPassword!)
                    self.tempUID = (user?.uid)!
                    self.performSegue(withIdentifier: "fromEntryToAddCard", sender: self)
                }
            })
        }
    }
    
    
    
    // MARK: IB Actions
    
    @IBAction func leftContainerButtonTapped(_ sender: UIButton) {
        leftButtonWasTappedWhichIsDefault()
        
    }
    
    @IBAction func rightContainerButtonTapped(_ sender: UIButton) {
        rightButtonWasTapped()
    }
    
    @IBAction func signInOrUpButtonTapped(_ sender: UIButton) {
        bottomContainerStateSwitcher()
    }
    
    
    // MARK: Keyboard Methods
    
    func keyboardWillShow(notification:NSNotification) {
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        var contentInset: UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 30
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
    
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        textField.resignFirstResponder()
        return false
    }
    
    
} // End of EntryPageViewController

extension LoginViewController: UITextFieldDelegate {
    
    // MARK: Add Delegate, Remove AutoCorrect, and Placeholder Color to Bottom TextFields
    
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
    
    
    // MARK: Text Field Targets
    
    func checkIfTopTextFIeldIsSatisfied(textField: UITextField) {
        if textField == self.textFieldOne {
            if self.leftOn == true && rightOn == false {
                if textField.text?.validateEmail() == true {
                    self.topFieldIsSatisfied = true
                } else {
                    self.topFieldIsSatisfied = false
                }
                checkIfBothSignInRequirementsAreMet()
            } else if leftOn == false && self.rightOn == true {
                if self.createUserStepOneFinished == true {
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
    
    
    func checkIfBottomTextFieldIsSatisfied(textField: UITextField) {
        if textField == self.textFieldTwo {
            if self.leftOn == true && rightOn == false {
                if textField.text?.isEmpty == true {
                    self.bottomFieldIsSatisfied = false
                } else {
                    self.bottomFieldIsSatisfied = true
                }
                checkIfBothSignInRequirementsAreMet()
            } else if self.leftOn == false && rightOn == false {
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
