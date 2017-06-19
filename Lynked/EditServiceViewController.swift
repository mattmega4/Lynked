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
import SafariServices

class EditServiceViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var leftNavBarButton: UIBarButtonItem!
    @IBOutlet weak var rightNavBarButton: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var serviceStateToggleSwtich: UISwitch!
    @IBOutlet weak var servieLabelTop: UILabel!
    @IBOutlet weak var updateServiceOnlineButton: UIButton!
    
    @IBOutlet weak var firstContainerView: UIView!
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var serviceNameTextField: UITextField!
    
    @IBOutlet weak var secondContainerView: UIView!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var secondContainerURLIndicatorButton: UIButton!
    
    @IBOutlet weak var thirdContainerView: UIView!
    @IBOutlet weak var fixedEpenseLabel: UILabel!
    @IBOutlet weak var fixedExpenseToggleSwitch: UISwitch!
    
    @IBOutlet weak var fourthContainerView: UIView!
    @IBOutlet weak var fixedAmountLabel: UILabel!
    @IBOutlet weak var fixedAmountTextField: UITextField!
    
    @IBOutlet weak var firstDividerView: UIView!
    @IBOutlet weak var secondDividerView: UIView!
    @IBOutlet weak var thirdDividerView: UIView!
    @IBOutlet weak var fourthDividerView: UIView!
    @IBOutlet weak var fifthDividerView: UIView!
    
    @IBOutlet weak var fifthContainerView: UIView!
    
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
    
    var nameForSite: String?
    var URLForSite: String?
    
    var service: ServiceClass?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.serviceNameTextField.delegate = self
        self.urlTextField.delegate = self
        self.fixedAmountTextField.delegate = self
        
        title = "Edit Service"
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
        //pullServiceData()
        alertUserIfURLTextFieldIsNotValid(textField: urlTextField)
        updateViewBasedOnService()
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
    
    
    func updateViewBasedOnService() {
        serviceStateToggleSwtich.isOn = service?.serviceStatus == true
        serviceNameTextField.text = service?.serviceName
        if let name = service?.serviceName {
            updateServiceOnlineButton.setTitle("Go To \(name)'s Website to Update Payment", for: .normal)
        }
        urlTextField.text = service?.serviceUrl
        fixedExpenseToggleSwitch.isOn = service?.serviceFixed == true
        fixedAmountTextField.text = "$\(service?.serviceAmount ?? 0.0)"
    }
    
    
    
    // MARK: Firebase Methods
    
    func updateServiceToFirebase() { // updateService
        
        FirebaseUtility.shared.update(service: service,
                                      name: serviceNameTextField.text,
                                      url: urlTextField.text, amount: fixedAmountTextField.text, isFixed: fixedExpenseToggleSwitch.isOn, state: serviceStateToggleSwtich.isOn) { (updatedService, errMessage) in
                                        self.navigationController?.popViewController(animated: true)
        }    
    }
    
    
    // MARK: Delete Service with UIAlert
    
    func deleteThisService() {
        
        let alertController = UIAlertController(title: "Wait!", message: "This will completely remove this service from your card. It will also be reflected in your total fixed monthly expenses if it was a fixed expense.", preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "Never Mind!", style: UIAlertActionStyle.cancel, handler: nil)
        let okAction = UIAlertAction(title: "I Understand!", style: UIAlertActionStyle.default) { (result: UIAlertAction) in
            
            let thisService = self.ref.child("services").child(self.thisServiceTransfered)
            
            let theServiceOnThisCard = self.ref.child("cards").child(self.thisCardTransfered).child("services").child(self.thisServiceTransfered)
            
            Analytics.logEvent("Service_Deleted", parameters: ["success" : true])
            
            Answers.logCustomEvent(withName: "Service Deleted",
                                   customAttributes: nil)
            
            thisService.removeValue()
            theServiceOnThisCard.removeValue()
            
            
            if let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "CardDetailVC") as? CardDetailViewController {
                //detailVC.cardID = self.thisCardTransfered
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
        navigationController?.popViewController(animated: true)
//        if let detailVC = storyboard?.instantiateViewController(withIdentifier: "CardDetailVC") as? CardDetailViewController {
//            //detailVC.cardID = thisCardTransfered
//            navigationController?.pushViewController(detailVC, animated: true)
//        }
    }
    
    @IBAction func rightNavBarButtonTapped(_ sender: UIBarButtonItem) {
        updateServiceToFirebase()
        rightNavBarButton.isEnabled = false
    }
    
    @IBAction func updateServiceOnlineButtonTapped(_ sender: UIButton) {
        if let sendURL = URLForSite {
            if let url = URL(string: "https://" + sendURL) {
                let svc = SFSafariViewController(url: url)
                self.present(svc, animated: true, completion: nil)
            }
        } else {
            if let tName = nameForSite {
                if let url = URL(string: "https://www.google.com/#q=\(tName)") {
                    let svc = SFSafariViewController(url: url)
                    self.present(svc, animated: true, completion: nil)
                }
            }
        }
    }
    
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        deleteThisService()
    }
    
    
}
