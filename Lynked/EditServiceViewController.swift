//
//  EditServiceViewController.swift
//  Lynked
//
//  Created by Matthew Singleton on 12/11/16.
//  Copyright © 2016 Matthew Singleton. All rights reserved.
//

import UIKit
import Firebase
import Fabric
import Crashlytics

class EditServiceViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var leftNavBarButton: UIBarButtonItem!
    @IBOutlet weak var rightNavBarButton: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var serviceStateToggleSwtich: UISwitch!
    @IBOutlet weak var servieLabelTop: UILabel!
    @IBOutlet weak var serviceLabelBottom: UILabel!
    @IBOutlet weak var firstDividerView: UIView!
    @IBOutlet weak var firstContainerView: UIView!
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var serviceNameTextField: UITextField!
    @IBOutlet weak var secondDividerView: UIView!
    @IBOutlet weak var secondContainerView: UIView!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var secondContainerURLIndicatorButton: UIButton!
    @IBOutlet weak var thirdDividerView: UIView!
    @IBOutlet weak var thirdContainerView: UIView!
    @IBOutlet weak var fixedEpenseLabel: UILabel!
    @IBOutlet weak var fixedExpenseToggleSwitch: UISwitch!
    @IBOutlet weak var fourthDividerView: UIView!
    @IBOutlet weak var fourthContainerView: UIView!
    @IBOutlet weak var fixedAmountLabel: UILabel!
    @IBOutlet weak var fixedAmountTextField: UITextField!
    @IBOutlet weak var fifthDividerView: UIView!
    @IBOutlet weak var deleteServiceButton: UIButton!
    
    var thisServiceTransfered = ""
    var thisCardTransfered = ""
    var thisCardNicknameTransfered = ""
    var thisCardTypeTransfered = ""
    var serviceUpToDateTransfered: Bool?
    var serviceNameTransfered: String?
    var serviceURLTransfered: String?
    var serviceFixedTransfered: Bool?
    var serviceAmountTransfered: String?
    let ref = Database.database().reference()
    let user = Auth.auth().currentUser
    var stateOfService: Bool?
    var stateOfFixed: Bool?
    var toStatus: Bool?
    var oneOrZero: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.serviceNameTextField.delegate = self
        self.urlTextField.delegate = self
        self.fixedAmountTextField.delegate = self
        setNavBar()
        addTargets()
        urlTextField.autocorrectionType = .no
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EditServiceViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        leftNavBarButton.isEnabled = true
        rightNavBarButton.isEnabled = true
        pullServiceData()
        alertUserIfURLTextFieldIsNotValid(textField: urlTextField)
    }
    
    
    // MARK: Nav Bar & View Design
    
    func setNavBar() {
        self.navigationController?.isNavigationBarHidden = false
        title = "Edit Service"
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
    
    
    // MARK: ADD Targets
    
    func addTargets() {
        serviceStateToggleSwtich.addTarget(self, action: #selector(stateSwitch(firstSwitch:)), for: .valueChanged)
        fixedExpenseToggleSwitch.addTarget(self, action: #selector(fixedSwitch(secondSwitch:)), for: .valueChanged)
        urlTextField.addTarget(self, action: #selector(alertUserIfURLTextFieldIsNotValid(textField:)), for: .editingChanged)
        fixedAmountTextField.addTarget(self, action: #selector(currencyRightToLeftFormatter(textField:)), for: .editingChanged)
    }
    
    
    
    
    // MARK: Switch Functions
    
    func stateSwitch(firstSwitch: UISwitch) {
        if firstSwitch.isOn {
            stateOfService = true
        } else {
            self.stateOfService = false
        }
    }
    
    
    func fixedSwitch(secondSwitch: UISwitch) {
        if secondSwitch.isOn {
            stateOfFixed = true
            fixedAmountLabel.alpha = 1.0
            fixedAmountTextField.isEnabled = true
        } else {
            stateOfFixed = false
            fixedAmountLabel.alpha = 0.4
            fixedAmountTextField.isEnabled = false
            fixedAmountTextField.text = ""
        }
    }
    
    
    
    
    // MARK: Firebase Methods
    
    func pullServiceData() {
        let serviceRef = ref.child("services")
        
        serviceRef.observe(DataEventType.value, with: { (snapshot) in
            
            for childs in snapshot.children {
                let allServiceID = (childs as AnyObject).key as String
                if allServiceID == self.thisServiceTransfered {
                    let thisServiceLocation = serviceRef.child(self.thisServiceTransfered)
                    
                    thisServiceLocation.observe(DataEventType.value, with: { (snap) in
                        
                        let thisServiceDetails = snap as DataSnapshot
                        
                        if let serviceDict = thisServiceDetails.value as? [String: AnyObject] {
                            
                            if let tempState = self.serviceUpToDateTransfered {
                                
                                self.stateOfService = tempState
                                
                                if tempState == true {
                                    self.oneOrZero = 0
                                } else {
                                    self.oneOrZero = 1
                                }
                                

                            }
                            
                            if let tempFixed = self.serviceFixedTransfered {
                                self.stateOfFixed = tempFixed
                            }
                            
                            if serviceDict["serviceStatus"] as! Bool == true {
                                self.stateOfService = true
                                self.serviceStateToggleSwtich.setOn(true, animated: true)
                            } else {
                                self.stateOfService = false
                                self.serviceStateToggleSwtich.setOn(false, animated: true)
                            }
                            
                            self.serviceNameTextField.text = serviceDict["serviceName"] as? String
                            
                            self.urlTextField.text = serviceDict["serviceURL"] as? String
                            
                            if serviceDict["serviceFixed"] as! Bool == true {
                                self.fixedExpenseToggleSwitch.setOn(true, animated: true)
                                self.fixedAmountLabel.alpha = 1.0
                                self.fixedAmountTextField.isEnabled = true
                                self.fixedAmountTextField.text = serviceDict["serviceAmount"] as? String
                            } else {
                                self.fixedExpenseToggleSwitch.setOn(false, animated: true)
                                self.fixedAmountLabel.alpha = 0.4
                                self.fixedAmountTextField.isEnabled = false
                                self.fixedAmountTextField.text = ""
                                self.fixedAmountTextField.text = serviceDict["serviceAmount"] as? String
                            }
                        }
                    })
                }
            }
        })
    }
    
    
    func saveServiceToFirebase() {
        let sName = serviceNameTextField.text ?? ""
        let sURL = urlTextField.text ?? ""
        let sAmount = fixedAmountTextField.text ?? ""
        let nameWhiteSpacesRemoved = sName.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let urlWhitepacesRemoved = sURL.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        var amountWhiteSpacesRemoved = sAmount.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if amountWhiteSpacesRemoved.hasPrefix("$") && amountWhiteSpacesRemoved.characters.count > 1 {
            amountWhiteSpacesRemoved.remove(at: amountWhiteSpacesRemoved.startIndex)
        }
        let thisService = ref.child("services").child(thisServiceTransfered)
        
        if let state = stateOfService {
            
            if state == true {
                thisService.setValue(["serviceURL": urlWhitepacesRemoved, "serviceName": nameWhiteSpacesRemoved, "serviceStatus": state, "serviceFixed": stateOfFixed!, "serviceAmount": amountWhiteSpacesRemoved, "attentionInt": 0])
            } else {
                thisService.setValue(["serviceURL": urlWhitepacesRemoved, "serviceName": nameWhiteSpacesRemoved, "serviceStatus": state, "serviceFixed": stateOfFixed!, "serviceAmount": amountWhiteSpacesRemoved, "attentionInt": 1])
            }

        }
        
        Analytics.logEvent("Details Added To Service", parameters: ["success" : true])
        
        Answers.logCustomEvent(withName: "Details Added To Service",
                              customAttributes: nil)
        
        if let detailVC = storyboard?.instantiateViewController(withIdentifier: "CardDetailVC") as? CardDetailViewController {
            detailVC.cardID = thisCardTransfered
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    
    // MARK: Delete Service with UIAlert
    
    func deleteThisService() {
        
        let alertController = UIAlertController(title: "Wait!", message: "This will completely remove this service from your card. It will also be reflected in your total fixed monthly expenses if it was a fixed expense.", preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "Never Mind!", style: UIAlertActionStyle.cancel, handler: nil)
        let okAction = UIAlertAction(title: "I Understand!", style: UIAlertActionStyle.default) { (result: UIAlertAction) in
            
            let thisService = self.ref.child("services").child(self.thisServiceTransfered)
            
            let theServiceOnThisCard = self.ref.child("cards").child(self.thisCardTransfered).child("services").child(self.thisServiceTransfered)
            
            Analytics.logEvent("Service Deleted", parameters: ["success" : true])
            
            Answers.logCustomEvent(withName: "Service Deleted",
                                   customAttributes: nil)
            
            thisService.removeValue()
            theServiceOnThisCard.removeValue()
            
            
            if let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "CardDetailVC") as? CardDetailViewController {
                detailVC.cardID = self.thisCardTransfered
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
            
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    // MARK: URL Validator
    
    func alertUserIfURLTextFieldIsNotValid(textField: UITextField) {
        if textField == urlTextField {
            if (textField.text?.isEmpty)! {
                secondContainerURLIndicatorButton.setImage(UIImage.init(named: "emptyBlue.png"), for: UIControlState())
                rightNavBarButton.isEnabled = true
            }  else if textField.text?.validateUrl() == false {
                secondContainerURLIndicatorButton.setImage(UIImage.init(named: "yellowCaution.png"), for: UIControlState())
                rightNavBarButton.isEnabled = false
            } else if textField.text?.validateUrl() == true {
                secondContainerURLIndicatorButton.setImage(UIImage.init(named: "greenCheck.png"), for: UIControlState())
                rightNavBarButton.isEnabled = true
            }
        }
    }
    
    
    // MARK: Money Input Method
    
    func currencyRightToLeftFormatter(textField: UITextField) {
        if textField == fixedAmountTextField {
            if let amountString = textField.text?.currencyInputFormatting() {
                textField.text = amountString
            }
        }
    }
    
    
    // MARK: Keyboard Methods
    
    func keyboardWillShow(notification:NSNotification) {
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        var contentInset: UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 30
        self.scrollView.contentInset = contentInset
        deleteServiceButton.isEnabled = false
        deleteServiceButton.isHidden = true
    }
    
    
    func keyboardWillHide(notification:NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInset
        deleteServiceButton.isEnabled = true
        deleteServiceButton.isHidden = false
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
    
    
    // MARK: IB Actions
    
    @IBAction func leftNavBarButtonTapped(_ sender: UIBarButtonItem) {
        leftNavBarButton.isEnabled = false
        if let detailVC = storyboard?.instantiateViewController(withIdentifier: "CardDetailVC") as? CardDetailViewController {
            detailVC.cardID = thisCardTransfered
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    @IBAction func urlIndicatorButtonTapped(_ sender: UIButton) {
        //
    }
    
    @IBAction func rightNavBarButtonTapped(_ sender: UIBarButtonItem) {
        saveServiceToFirebase()
        rightNavBarButton.isEnabled = false
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        deleteThisService()
    }
    
    
}
