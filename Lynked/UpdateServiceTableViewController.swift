//
//  UpdateServiceTableViewController.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 7/3/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit
import SafariServices

class UpdateServiceTableViewController: UITableViewController {
  
  
  @IBOutlet weak var leftNavBarButton: UIBarButtonItem!
  
  @IBOutlet weak var headerView: UIView!
  @IBOutlet weak var serviceCurrentSwitch: UISwitch!
  @IBOutlet weak var serviceCurrentLabel: UILabel!
  @IBOutlet weak var serviceCurrentButton: UIButton!
  @IBOutlet weak var bottomHeaderDividerView: UIView!
  
  // Basic Cells
  @IBOutlet weak var nameCell: ServiceDetailTableViewCell!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var nameTextField: UITextField!
  
  @IBOutlet weak var urlCell: ServiceDetailTableViewCell!
  @IBOutlet weak var urlLabel: UILabel!
  @IBOutlet weak var urlTextField: UITextField!
  
  @IBOutlet weak var categoryCell: ServiceDetailTableViewCell!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var categoryTextField: UITextField!
  
  // Advanced Cells
  @IBOutlet weak var amountAndFixedCell: ServiceDetailTableViewCell!
  @IBOutlet weak var amountLabel: UILabel!
  @IBOutlet weak var fixedLabel: UILabel!
  @IBOutlet weak var amountTextField: UITextField!
  @IBOutlet weak var fixedSwitch: UISwitch!
  
  @IBOutlet weak var paymentIncrimentCell: ServiceDetailTableViewCell!
  @IBOutlet weak var paymentIncrimentLabel: UILabel!
  @IBOutlet weak var paymentIncrimentTextField: UITextField!
  
  @IBOutlet weak var paymentDateCell: ServiceDetailTableViewCell!
  @IBOutlet weak var paymentDateLabel: UILabel!
  @IBOutlet weak var paymentDateTextField: UITextField!
  
  @IBOutlet weak var footerView: UIView!
  @IBOutlet weak var footerTopDividerView: UIView!
  @IBOutlet weak var saveButton: UIButton!
  @IBOutlet weak var deleteButton: UIButton!
  
  var servState: Bool?
  var servName: String?
  var servUrl: String?
  var servFixed = false
  var servCategory: String?
  var servAmount: String?
  var servPayRate: String?
  var servScheduled: Double?
  
  var service: Service?
  
  let categoryPicker = UIPickerView()
  let payRatePicker = UIPickerView()
  let datePicker = UIDatePicker()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.nameTextField.delegate = self
    self.urlTextField.delegate = self
    self.categoryTextField.delegate = self
    self.amountTextField.delegate = self
    self.paymentIncrimentTextField.delegate = self
    self.paymentDateTextField.delegate = self
    
    self.categoryPicker.delegate = self
    self.categoryPicker.dataSource = self
    self.payRatePicker.delegate = self
    self.payRatePicker.dataSource = self
    
    datePicker.datePickerMode = .date
    
    datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
    
    serviceCurrentSwitch.addTarget(self, action: #selector(currentSwitchTarget(aSwitch:)), for: .valueChanged)
    fixedSwitch.addTarget(self, action: #selector(fixedSwitchTarget(aSwitch:)), for: .valueChanged)
    
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UpdateServiceTableViewController.dismissKeyboard))
    view.addGestureRecognizer(tap)
    
    updateViewBasedOnService()
  }
  
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
  }
  
  // MARK: - UISwitch Target
  
  func currentSwitchTarget(aSwitch: UISwitch) {
    if aSwitch == serviceCurrentSwitch {
      servState = serviceCurrentSwitch.isOn
    }
  }
  
  
  func fixedSwitchTarget(aSwitch: UISwitch) {
    if aSwitch == fixedSwitch {
      servFixed = fixedSwitch.isOn
      print(servFixed)
    }
  }
  
  
  // MARK: - Update Views
  
  func updateViewBasedOnService() {
    servState = service?.serviceStatus
    serviceCurrentSwitch.isOn = service?.serviceStatus == true
    if let name = service?.serviceName {
      servName = name
      title = "\(name) Details"
      serviceCurrentButton.setTitle("Update \(name) Billing Info", for: .normal)
      nameTextField.text = name
    }
    if let url = service?.serviceUrl {
      servUrl = url
      urlTextField.text = url
    }
    servFixed = service?.serviceFixed ?? false
    fixedSwitch.isOn = servFixed
    
    if let theAmount = service?.serviceAmount {
      servAmount = String(theAmount)
      amountTextField.text = String(theAmount)
    }
    if let theCat = service?.category {
      servCategory = theCat
      categoryTextField.text = theCat
    }
    if let theRate = service?.paymentRate{
      servPayRate = theRate
      paymentIncrimentTextField.text = theRate
    }
    if let theService = service {
      if let theScheduled = ServicePayRateManager.shared.getNextPaymentDateFor(service: theService) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        paymentDateTextField.text = formatter.string(from: theScheduled)
        servScheduled = theScheduled.timeIntervalSinceReferenceDate
      }
    }
  }
  
  
  // MARK: - Date Picker Target
  
  func datePickerValueChanged(_ sender: UIDatePicker) {
    let date = sender.date
    servScheduled = date.timeIntervalSinceReferenceDate
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM dd, yyyy"
    paymentDateTextField?.text = formatter.string(from: date)
    service?.nextPaymentDate = date
  }
  
  
  // MARK: - Update Service
  
  func updateServiceToFirebase() {
    if servFixed {
      FirebaseUtility.shared.update(service: service,
                                    name: nameTextField?.text,
                                    url: urlTextField?.text,
                                    amount: amountTextField?.text,
                                    isFixed: true,
                                    state: serviceCurrentSwitch.isOn,
                                    rate: paymentIncrimentTextField?.text,
                                    scheduled: servScheduled,
                                    categ: categoryTextField?.text,
                                    paymentDate: datePicker.date,
                                    completion: { (updatedService, errMessage) in
                                      FirebaseUtility.shared.getAllServices { (services, error) in }
                                      self.navigationController?.popViewController(animated: true)
      })
      
    } else {
      
      FirebaseUtility.shared.update(service: service,
                                    name: nameTextField?.text,
                                    url: urlTextField?.text,
                                    amount: nil,
                                    isFixed: false,
                                    state: serviceCurrentSwitch.isOn,
                                    rate: nil,
                                    scheduled: nil,
                                    categ: categoryTextField?.text,
                                    paymentDate: nil,
                                    completion: { (updatedService, errMessage) in
                                      self.navigationController?.popViewController(animated: true)
      })
      
    }
    
  }
  
  
  // MARK: - Delete Service with UIAlert
  
  func deleteThisService() {
    
    let alertController = UIAlertController(title: "Wait!", message: "This will completely remove this service from your card. It will also be reflected in your total fixed monthly expenses if it was a fixed expense.", preferredStyle: UIAlertControllerStyle.alert)
    let cancelAction = UIAlertAction(title: "Never Mind!", style: UIAlertActionStyle.cancel, handler: nil)
    
    let okAction = UIAlertAction(title: "I Understand!", style: UIAlertActionStyle.default) { (result: UIAlertAction) in
      
      guard let theService = self.service else {
        return
      }
      
      FirebaseUtility.shared.delete(service: theService, completion: { (success, error) in
        
        if let errorMessage = error {
          print(errorMessage)
        } else if success {
          var didGoBack = false
          if let viewControllers = self.navigationController?.viewControllers {
            for aController in viewControllers {
              if aController is ServiceListViewController {
                didGoBack = true
                self.navigationController?.popToViewController(aController, animated: true)
                break
              }
            }
            
          }
          if !didGoBack {
            if let walletVC = self.storyboard?.instantiateViewController(withIdentifier: WALLET_STORYBOARD_IDENTIFIER) as? WalletViewController {
              self.navigationController?.pushViewController(walletVC, animated: true)
            }
          }
        }
      })
    }
    
    alertController.addAction(cancelAction)
    alertController.addAction(okAction)
    
    self.present(alertController, animated: true, completion: nil)
  }
  
  
  // MARK: - Update Service on Service Website
  
  func updateServiceOnServiceWebsite() {
    if let sendURL = servUrl {
      if let url = URL(string: "https://" + sendURL) {
        let svc = SFSafariViewController(url: url)
        self.present(svc, animated: true, completion: nil)
      }
    } else {
      if let tName = servName {
        if let url = URL(string: "https://www.google.com/#q=\(tName)") {
          let svc = SFSafariViewController(url: url)
          self.present(svc, animated: true, completion: nil)
        }
      }
    }
  }
  
  
  // MARK: - Keyboard Methods
  
  func textFieldShouldClear(_ textField: UITextField) -> Bool {
    textField.endEditing(true)
    return true
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.endEditing(true)
    textField.resignFirstResponder()
    return false
  }
  
  
  // MARK: - IBActions
  
  @IBAction func leftNavBarButtonTapped(_ sender: UIBarButtonItem) {
    navigationController?.popViewController(animated: true)
  }
  
  @IBAction func serviceUpdateBillingButtonTapped(_ sender: UIButton) {
    updateServiceOnServiceWebsite()
  }
  
  @IBAction func saveButtonTapped(_ sender: UIButton) {
    updateServiceToFirebase()
  }
  
  @IBAction func deleteButtonTapped(_ sender: UIButton) {
    deleteThisService()
  }
  
  
  
  
}


// MARK: - UIPickerView Delegate Methods

extension UpdateServiceTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    if pickerView == categoryPicker {
      return CategoryManager.shared.categories.count
      
    }
    return ServicePayRateManager.shared.payRates.count
    
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    
    if pickerView == categoryPicker {
      return CategoryManager.shared.categories[row]
      
    }
    return ServicePayRateManager.shared.payRates[row]
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    if pickerView == categoryPicker {
      categoryTextField?.text = CategoryManager.shared.categories[row]
      service?.category = CategoryManager.shared.categories[row]
    } else {
      paymentIncrimentTextField?.text = ServicePayRateManager.shared.payRates[row]
      service?.paymentRate = ServicePayRateManager.shared.payRates[row]
    }
  }
}


// MARK: - UITextField Delegate

extension UpdateServiceTableViewController: UITextFieldDelegate {
  
  func myTextFieldDidChange(_ textField: UITextField) {
    if let amountString = textField.text?.currencyInputFormatting() {
      textField.text = amountString
    }
  }
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    if textField == categoryTextField {
      categoryTextField.inputView = categoryPicker
    } else if textField == paymentIncrimentTextField {
      paymentIncrimentTextField.inputView = payRatePicker
    } else if textField == paymentDateTextField {
      paymentDateTextField.inputView = datePicker
    }
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    if textField == nameTextField {
      service?.serviceName = textField.text
    }
    else if textField == urlTextField {
      service?.serviceUrl = textField.text
    }
      
    else if textField == amountTextField {
      if let amount = amountTextField?.text {
        if let theAmount = Double(amount) {
          service?.serviceAmount = theAmount
        }
      }
    }
  }
  
  
}
