//
//  ServiceDetailTableViewController.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 6/21/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit
import SafariServices


class ServiceDetailViewController: UITableViewController {
    
    @IBOutlet weak var leftNavBarButton: UIBarButtonItem!
    
    @IBOutlet weak var serviceBillingCurrentSwitch: UISwitch!
    @IBOutlet weak var serviceBillingCurrentLabel: UILabel!
    @IBOutlet weak var serviceUpdateBillingButton: UIButton!
    
    @IBOutlet weak var serviceTableView: UITableView!
    
    @IBOutlet weak var saveServiceButton: UIButton!
    @IBOutlet weak var deleteServiceButton: UIButton!
    
    var servState: Bool?
    var servName: String?
    var servUrl: String?
    var servFixed = false
    var servCategory: String?
    var servAmount: String?
    var servPayRate: String?
    var servScheduled: Double?
    
    var service: ServiceClass?
    
    let serviceCellIdentifier = "serviceCell"
    
    let items: [[String : Any]] =
        [["title" : "Name", "placeholder" : "Netflix", "hasSwitch" : false],
         ["title" : "URL", "placeholder" : "netflix.com", "hasSwitch" : false],
         ["title" : "Category", "placeholder" : "Entertainment", "hasSwitch" : false],
         ["title" : "Pay Amount", "placeholder" : "9.99", "hasSwitch" : true],
         ["title" : "Pay Rate", "placeholder" : "Monthy", "hasSwitch" : false],
         ["title" : "Next Scheduled Payment", "placeholder" : "15th of May", "hasSwitch" : false]]
    
    let categoryPicker = UIPickerView()
    let payRatePicker = UIPickerView()
    
    let datePicker = UIDatePicker()
    
    var nameTextField: UITextField?
    var urlTextField: UITextField?
    var categoryTextField: UITextField?
    var amountTextField: UITextField?
    var rateTextField: UITextField?
    var dateTextField: UITextField?
    
    var fixedSwitch: UISwitch?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavBar()
        self.serviceTableView.delegate = self
        self.serviceTableView.dataSource = self
        
        self.categoryPicker.delegate = self
        self.categoryPicker.dataSource = self
        
        self.payRatePicker.delegate = self
        self.payRatePicker.dataSource = self
        
        self.nameTextField?.delegate = self
        self.urlTextField?.delegate = self
        self.amountTextField?.delegate = self
        self.dateTextField?.delegate = self
        
        
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ServiceDetailViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        updateViewBasedOnService()
    }
    
    func datePickerValueChanged(_ sender: UIDatePicker) {
        let date = sender.date
        servScheduled = date.timeIntervalSinceReferenceDate
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        dateTextField?.text = formatter.string(from: date)
        service?.nextPaymentDate = date
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    // MARK: - Update Views
    
    func updateViewBasedOnService() {
        servState = service?.serviceStatus
        serviceBillingCurrentSwitch.isOn = service?.serviceStatus == true
        if let name = service?.serviceName {
            servName = name
            title = "\(name) Details"
            serviceUpdateBillingButton.setTitle("Update \(name) Billing Info", for: .normal)
        }
        if let url = service?.serviceUrl {
            servUrl = url
        }
        servFixed = service?.serviceFixed ?? true
        if let theAmount = service?.serviceAmount {
            servAmount = String(theAmount)
        }
        servCategory = service?.category
        servPayRate = service?.paymentRate
        servScheduled = (service?.nextPaymentDate ?? Date()).timeIntervalSinceReferenceDate
    }
    
    
    // MARK: - Firebase Methods
    
    func updateServiceToFirebase() {
        if servFixed {
            FirebaseUtility.shared.update(service: service,
                                          name: nameTextField?.text,
                                          url: urlTextField?.text,
                                          amount: amountTextField?.text,
                                          isFixed: true,
                                          state: serviceBillingCurrentSwitch.isOn,
                                          rate: rateTextField?.text,
                                          scheduled: servScheduled,
                                          categ: categoryTextField?.text,
                                          paymentDate: datePicker.date,
                                          completion: { (updatedService, errMessage) in
                                            self.navigationController?.popViewController(animated: true)
            })
            
        } else {
            
            FirebaseUtility.shared.update(service: service,
                                          name: nameTextField?.text,
                                          url: urlTextField?.text,
                                          amount: nil,
                                          isFixed: false,
                                          state: serviceBillingCurrentSwitch.isOn,
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
                            if aController is ServicesViewController {
                                didGoBack = true
                                self.navigationController?.popToViewController(aController, animated: true)
                                break
                            }
                        }
                        
                    }
                    if !didGoBack {
                        if let walletVC = self.storyboard?.instantiateViewController(withIdentifier: "WalletVC") as? WalletViewController {
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
    
    func keyboardWillShow(notification:NSNotification) {
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        var contentInset: UIEdgeInsets = self.tableView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 30
        self.tableView.contentInset = contentInset
        deleteServiceButton.isEnabled = false
        deleteServiceButton.isHidden = true
    }
    
    func keyboardWillHide(notification:NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.tableView.contentInset = contentInset
        deleteServiceButton.isEnabled = true
        deleteServiceButton.isHidden = false
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        textField.resignFirstResponder()
        return false
    }
    
    
    
    
    // MARK: - IB Actions
    
    @IBAction func leftNavBarButtonTapped(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func serviceUpdateBillingButtonTapped(_ sender: UIButton) {
        updateServiceOnServiceWebsite()
    }
    
    @IBAction func saveServiceButtonTapped(_ sender: UIButton) {
        updateServiceToFirebase()
    }
    
    @IBAction func deleteServiceButtonTapped(_ sender: UIButton) {
        deleteThisService()
    }
    
} // MARK: - End of ServiceDetailViewController



// MARK: - UITextField Delegates

extension ServiceDetailViewController: UITextFieldDelegate {
    
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
    
    
    //    func currencyRightToLeftFormatter(textField: UITextField) {
    //        if textField == amountTextField {
    //            if let amountString = textField.text?.currencyInputFormatting() {
    //                textField.text = amountString
    //            }
    //        }
    //    }
}

// MARK: - UIPickerView Delegate Methods

extension ServiceDetailViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
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
            rateTextField?.text = ServicePayRateManager.shared.payRates[row]
            service?.paymentRate = ServicePayRateManager.shared.payRates[row]
        }
    }
}


// MARK: - UITableView Delegate & DataSource Methods

extension ServiceDetailViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: serviceCellIdentifier, for: indexPath as IndexPath) as! ServiceDetailTableViewCell
        let item = items[indexPath.row]
        
        cell.serviceTitleLabel.text = item["title"] as? String
        
        cell.serviceTextField.placeholder = item["placeholder"] as? String
        
        cell.fixedToggleSwitch?.isHidden = item["hasSwitch"] as? Bool != true
        
        
        if cell.fixedToggleSwitch?.isHidden == false {
            fixedSwitch = cell.fixedToggleSwitch
            fixedSwitch?.isOn = service?.serviceFixed == true
        }
        
        cell.delegate = self
        

        
        
        
        
        switch indexPath.row {
        case 0:
            cell.serviceTextField.text = service?.serviceName
            nameTextField = cell.serviceTextField
            nameTextField?.keyboardType = .default
        case 1:
            cell.serviceTextField.text = service?.serviceUrl
            urlTextField = cell.serviceTextField
            urlTextField?.keyboardType = .URL
        case 2:
            cell.serviceTextField.text = service?.category
            cell.serviceTextField.inputView = categoryPicker
            categoryTextField = cell.serviceTextField
        case 3:
            cell.serviceTextField.isEnabled = self.servFixed
            if let amount = service?.serviceAmount {
                cell.serviceTextField.text = String(amount)
                
                cell.serviceTextField.keyboardType = .decimalPad
            }
            amountTextField = cell.serviceTextField
            
            
            
            //            currencyInputFormatting()
            
            cell.fixedToggleSwitch?.isOn = servFixed
        case 4:
            cell.serviceTextField.isEnabled = self.servFixed
            cell.serviceTextField.text = service?.paymentRate
            cell.serviceTextField.inputView = payRatePicker
            rateTextField = cell.serviceTextField
        case 5:
            cell.serviceTextField.isEnabled = self.servFixed
            if let theService = service {
                if let paymentDate = ServicePayRateManager.shared.getNextPaymentDateFor(service: theService) {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MMM dd, yyyy"
                    cell.serviceTextField.text = formatter.string(from: paymentDate)
                    
                }
                cell.serviceTextField.inputView = datePicker
            }
            else {
                cell.serviceTextField.text = ""
            }
            dateTextField = cell.serviceTextField
        default:
            print("HOW DID I GET HERE?")
        }
        
        return cell
  
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}


extension ServiceDetailViewController: ServiceDetailTableViewCellDelegate {

    func serviceDetailTableViewCell(cell: ServiceDetailTableViewCell, didChangeFixedSwitch fixedSwitch: UISwitch) {
        servFixed = fixedSwitch.isOn
        tableView.reloadData()
    }
}





