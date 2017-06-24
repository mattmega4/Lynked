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

    
    var servName: String?
    var servUrl: String?
//    var servState: Bool?
    var servFixed: Bool?
    var servCategory: String?
    var servAmount: Double?
//    var payRateInx: Int?
    
    var service: ServiceClass?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavBar()
        self.serviceTableView.delegate = self
        self.serviceTableView.dataSource = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ServiceDetailViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateViewBasedOnService()
    }
    
    
    // MARK: - Update Views
    
    func updateViewBasedOnService() {

        serviceBillingCurrentSwitch.isOn = service?.serviceStatus == true
        if let name = service?.serviceName {
            servName = name
            title = "\(name) Details"
            serviceUpdateBillingButton.setTitle("Go To \(name)'s Website to Update Payment", for: .normal)
        }
        if let url = service?.serviceUrl {
            servUrl = url
        }
        servFixed = service?.serviceFixed
                servAmount = service?.serviceAmount ?? 0.0
        
        //        payRateInx = service?.servicePayRateIndex ?? 0
    }
    
    
    // MARK: - Firebase Methods
    
    func updateServiceToFirebase() {
        
//        FirebaseUtility.shared.update(service: service,
//                                      name: service.text,
//                                      url: urlTextField.text,
//                                      amount: fixedAmountTextField.text,
//                                      isFixed: fixedExpenseToggleSwitch.isOn,
//                                      state: serviceStateToggleSwtich.isOn,
//                                      rate: timeFrame ) { (updatedService, errMessage) in
//                                        
//                                        self.navigationController?.popViewController(animated: true)
//        }
    }
    
    
    // MARK: - Delete Service with UIAlert
    
    func deleteThisService() {
        
        let alertController = UIAlertController(title: "Wait!", message: "This will completely remove this service from your card. It will also be reflected in your total fixed monthly expenses if it was a fixed expense.", preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "Never Mind!", style: UIAlertActionStyle.cancel, handler: nil)
        
        let okAction = UIAlertAction(title: "I Understand!", style: UIAlertActionStyle.default) { (result: UIAlertAction) in
            
            guard let theService = self.service else {
                return
            }
            
            FirebaseUtility.shared.delete(service: theService,
                                          completion: { (success, error) in
                                            
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
        self.view.endEditing(true)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
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
        //        updateServiceToFirebase()
    }
    
    @IBAction func deleteServiceButtonTapped(_ sender: UIButton) {
        //        deleteThisService()
    }
    
    
    
} // MARK: - End of ServiceDetailViewController


// MARK: - UITableView Delegate & DataSource Methods

extension ServiceDetailViewController {
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! ServiceNameTableViewCell
            let row = indexPath.row
            cell.serviceNameTextField.text = servName
            return cell
            
        } else if indexPath.row == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! ServiceURLTableViewCell
            let row = indexPath.row
            cell.serviceUrlLabel.text = servUrl
            return cell
            
        } else if indexPath.row == 2 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! ServiceCategoryTableViewCell
            let row = indexPath.row
            // PAss from prev VC
            if let index = CategoryManager.shared.categories.index(where: {$0 == self.category}) {
                cell.serviceCategoryPicker.selectRow(index, inComponent: 0, animated: false)
            }
            
            
            return cell
            
        } else if indexPath.row == 3 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! ServiceFixedAndRateTableViewCell
            let row = indexPath.row
            cell.serviceFixedRatePicker.selectedRow(inComponent: 0)
            return cell
            
        } else /*if indexPath.row == 4*/ {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! ServiceNextScheduledTableViewCell
            let row = indexPath.row
            //            cell.serviceScheduledDatePicker.setDate(<#T##date: Date##Date#>, animated: <#T##Bool#>)
            return cell
            
        }
        
    }
    
    
    
    
}








