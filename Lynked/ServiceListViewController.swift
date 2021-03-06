//
//  ServiceListViewController.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 7/3/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit
import Kingfisher
import MBProgressHUD
import DZNEmptyDataSet
import Firebase
import FirebaseAnalytics
import Fabric
import Crashlytics


class ServiceListViewController: UIViewController {
  
  @IBOutlet weak var firstContainerView: UIView!
  @IBOutlet weak var addServiceTextField: UITextField!
  @IBOutlet weak var leftDividerView: UIView!
  @IBOutlet weak var categoryTextField: UITextField!
  @IBOutlet weak var rightDividerView: UIView!
  @IBOutlet weak var addButton: UIButton!
  @IBOutlet weak var firstDividerView: UIView!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var editCardButton: UIButton!
  
  
  let categoryPickerView = UIPickerView()
  var serviceArray = [Service]()
  var categories = [String]()
  var isDisplayingCategories = false
  var card: Card?
  var references = [DatabaseReference]()
  
  let SERVICE_CELL_IDENTIFIER = "servCell"
  let CATEGORY_CELL_IDENTIFIER = "categoryCell"
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setNavBar()
    addDelegates()
    
    addServiceTextField.addTarget(self, action: #selector(enableAddButton(textField:)), for: .editingChanged)
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ServiceListViewController.dismissKeyboard))
    view.addGestureRecognizer(tap)
    tap.cancelsTouchesInView = false
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    
    title = card?.nickname
    
    if UIDevice.current.userInterfaceIdiom == .pad {
      navigationItem.leftBarButtonItem = nil
      navigationItem.rightBarButtonItem = nil
    }
    print("ddfdfjadlfjaljf;lasjfajsf;lsj;jks")
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    
    addButton.alpha = 0.4
    addButton.isEnabled = false
    serviceArray.removeAll()
    tableView.reloadData()
    getServices()
    sortArray()
    showReview()
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    for ref in references {
      ref.removeAllObservers()
    }
    serviceArray.removeAll()
    tableView.reloadData()
    
  }
  
  // MARK: - Sort Array
  
  func sortArray() {
    self.serviceArray.sort {
      if $0.serviceAttention == $1.serviceAttention {
        return $0.serviceName ?? "" < $1.serviceName ?? ""
      }
      return $0.serviceAttention > $1.serviceAttention
    }
  }
  
  
  // MARK: - Get Services
  
  func getServices() {
    if let theCard = card {
       let getServiceTrace = Performance.startTrace(name: "getServices")
      FirebaseUtility.shared.getServicesFor(card: theCard) { (services, error, ref) in
        getServiceTrace?.stop()
        self.references.append(ref)
        if let theServices = services {
          
          self.serviceArray.removeAll()
          self.serviceArray = theServices
          self.getCategories()
          self.sortArray()
          
          self.tableView.reloadData()
          
          
        } else {
          if let theError = error?.localizedDescription {
            let errorMessage = theError
            print(errorMessage)
          }
        }
      }
    } else {
      navigationController?.popViewController(animated: true)
    }
  }
  
  
  // MARK: - Get Categories
  
  func getCategories() {
    
    let allCategories = serviceArray.flatMap({ (service) -> String? in
      return service.category
    })
    
    categories = Array(Set(allCategories))
    categories.sort { (category1, category2) -> Bool in
      return allCategories.filter({$0 == category1}).count > allCategories.filter({$0 == category2}).count
    }
  }
  
  // MARK: - Add Service
  
  func addService(service: Service) {
    serviceArray.append(service)
    sortArray()
  }
  
  
  func addServiceToCard() {
    MBProgressHUD.showAdded(to: self.view, animated: true)
    FirebaseUtility.shared.addService(name: addServiceTextField.text?.capitalized, forCard: card, withCategory: categoryTextField.text) { (service, errMessage) in
      MBProgressHUD.hide(for: self.view, animated: true)
      
      Analytics.logEvent(AnalyticsKeys.newServiceAdded, parameters: [AnalyticsKeys.success : true])
      
      Answers.logCustomEvent(withName: AnalyticsKeys.newServiceAdded,
                             customAttributes: nil)
      
      if let theService = service {
        self.addService(service: theService)
        
        self.addServiceTextField.text = nil
        self.categoryTextField.text = nil
        self.addButton.alpha = 0.4
        self.addButton.isEnabled = false
        self.getCategories()
        self.tableView.reloadData()
        
        if let index = self.serviceArray.index(where: {$0.serviceName == theService.serviceName}) {
          let indexPath = IndexPath(row: index, section: 0)
          self.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        }
      }
    }
  }
  
  
  // MARK: - Add Delegates & DataSources
  
  func addDelegates() {
    self.addServiceTextField.delegate = self
    self.categoryTextField.delegate = self
    self.categoryPickerView.delegate = self
    self.categoryPickerView.dataSource = self
    self.tableView.delegate = self
    self.tableView.dataSource = self
    self.tableView.emptyDataSetSource = self
    self.tableView.emptyDataSetDelegate = self
  }
  
  
  // MARK: - IBActions
  
  @IBAction func rightNavBarButtonTapped(_ sender: UIBarButtonItem) {
    if let prefVC = self.storyboard?.instantiateViewController(withIdentifier: StoryboardKeys.profileViewControllerStoryboardID) as? ProfileViewController {
      let prefNavigation = UINavigationController(rootViewController: prefVC)
      self.splitViewController?.present(prefNavigation, animated: true, completion: nil)
    }
  }
  
  @IBAction func editCardButtonTapped(_ sender: UIButton) {
    if let editCardVC = storyboard?.instantiateViewController(withIdentifier: StoryboardKeys.editCardViewControllerStoryboardID) as? EditCardViewController {
      if let theId = card?.cardID {
        editCardVC.thisCardIDTransfered = theId
      }
      editCardVC.serviceArray = serviceArray
      editCardVC.card = card
      navigationController?.pushViewController(editCardVC, animated: true)
    }
  }
  
  @IBAction func addServiceButtonTapped(_ sender: UIButton) {
    addServiceToCard()
  }
  
  @IBAction func changeSegment(sender: UISegmentedControl) {
    isDisplayingCategories = sender.selectedSegmentIndex == 1
    tableView.reloadData()
  }
  
  
  // MARK: - Keyboard Methods
  
  @objc func keyboardWillShow(notification:NSNotification) {
    var userInfo = notification.userInfo!
    var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
    keyboardFrame = self.view.convert(keyboardFrame, from: nil)
    var contentInset: UIEdgeInsets = self.tableView.contentInset
    contentInset.bottom = keyboardFrame.size.height
    self.tableView.contentInset = contentInset
  }
  
  @objc func keyboardWillHide(notification:NSNotification) {
    let contentInset:UIEdgeInsets = UIEdgeInsets.zero
    self.tableView.contentInset = contentInset
  }
  
}

// MARK: - UIPickerView Delegate & DataSource Methods

extension ServiceListViewController: UIPickerViewDelegate, UIPickerViewDataSource {
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return CategoryManager.shared.categories.count
  }
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return CategoryManager.shared.categories[row]
  }
  
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    let category = CategoryManager.shared.categories[row]
    categoryTextField.text = category
  }
  
}

// MARK: - UITextField Delegate Methods

extension ServiceListViewController: UITextFieldDelegate {
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    if textField == categoryTextField {
      categoryTextField.inputView = categoryPickerView
    }
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == addServiceTextField {
      addServiceTextField.returnKeyType = .next
      categoryTextField.becomeFirstResponder()
    } else if textField == categoryTextField {
      textField.returnKeyType = .go
      addServiceToCard()
      view.endEditing(true)
    }
    return false
  }
  
  func textFieldShouldClear(_ textField: UITextField) -> Bool {
    self.view.endEditing(true)
    return true
  }
  
  @objc func enableAddButton(textField: UITextField) {
    if (textField.text?.isEmpty)! {
      addButton.isEnabled = false
      addButton.alpha = 0.4
    } else if !(textField.text?.isEmpty)! {
      addButton.isEnabled = true
      addButton.alpha = 1.0
    }
  }
}

// MARK: - UITableView Delegates & DataSource

extension ServiceListViewController: UITableViewDelegate, UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if !isDisplayingCategories {
      return serviceArray.count
    }
    return categories.count
  }
  
  
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if !isDisplayingCategories {
      let cell = tableView.dequeueReusableCell(withIdentifier: SERVICE_CELL_IDENTIFIER, for: indexPath) as! ServiceTableViewCell
      let service = serviceArray[indexPath.row]
      
      cell.serviceColorStatusView.backgroundColor = service.serviceStatus ? .green : .red
      cell.serviceNameLabel.text = service.serviceName
      cell.serviceCategoryLabel.text = service.category
      cell.serviceAmountLabel.text = String("$\(service.serviceAmount)")
      
      if let fxed = service.serviceFixed {
        if fxed == true {
          
          if let dueDate = ServicePayRateManagerUtility.shared.getNextPaymentDateFor(service: service) {
            let date = dueDate
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM dd, yyyy"
            cell.serviceDueDateLabel.text = formatter.string(from: date)
          }
        } else {
          cell.serviceDueDateLabel.text = nil
        }
      }
      
      //      let placeholderImage = UIImage.init(named: "\(TempLetterImagePickerUtility.shared.getLetterOrNumberAndChooseImage(text: service.serviceName!))")
      let placeholderImage = InitialImageFactory.imageWith(name: service.serviceName)
      
      
      
      if let serviceURLString = service.serviceUrl { //, service.serviceUrl?.isEmpty == false {
        if serviceURLString.isEmpty {
          if let thePlaceholderImage = placeholderImage as? Resource {
            cell.serviceLogoImageVIew.kf.setImage(with: thePlaceholderImage)
          }
        }
        
        if let imageURL = URL(string: "https://logo.clearbit.com/\(serviceURLString)") {
          cell.serviceLogoImageVIew.kf.setImage(with: imageURL, placeholder: placeholderImage, options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, url) in
            if image == nil {
              let myURLString: String = "http://www.google.com/s2/favicons?domain=\(serviceURLString)"
              if let myURL = URL(string: myURLString) {
                cell.serviceLogoImageVIew.kf.setImage(with: myURL, placeholder: placeholderImage)
              }
            }
          })
        }
        return cell
      }
    }
    
    
    let cell = tableView.dequeueReusableCell(withIdentifier: CATEGORY_CELL_IDENTIFIER, for: indexPath) as! CategoryTableViewCell
    cell.categoryLabel.text = categories[indexPath.row]
    let categoryServices = serviceArray.filter({$0.category == categories[indexPath.row]})
    for i in 0..<min(categoryServices.count, 3) {
      let service = categoryServices[i]
      
      //      let placeholderImage = UIImage.init(named: "\(TempLetterImagePickerUtility.shared.getLetterOrNumberAndChooseImage(text: service.serviceName!))")
      
      let placeholderImage = InitialImageFactory.imageWith(name: service.serviceName)
      
      
      if let seviceURLString = service.serviceUrl, service.serviceUrl?.isEmpty == false {
        let myURLString: String = "https://logo.clearbit.com/\(seviceURLString)"
        if let myURL = URL(string: myURLString) {
          switch i {
          case 0:
            cell.categoryImageOne.kf.setImage(with: myURL, placeholder: placeholderImage)
          case 1:
            cell.categoryImageTwo.kf.setImage(with: myURL, placeholder: placeholderImage)
          case 2:
            cell.categoryImageThree.kf.setImage(with: myURL, placeholder: placeholderImage)
          case 3:
            cell.categoryImageFour.kf.setImage(with: myURL, placeholder: placeholderImage)
          default:
            print("error")
          }
        }
      }
    }
    return cell
  }
  
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if !isDisplayingCategories {
      if let serviceDetailVC = storyboard?.instantiateViewController(withIdentifier: StoryboardKeys.serviceDetailViewControllerStoryboardID) as? UpdateServiceTableViewController {
        serviceDetailVC.service = self.serviceArray[indexPath.row]
        navigationController?.pushViewController(serviceDetailVC, animated: true)
      }
    } else {
      //
    }
  }
  
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    
    return true
  }
  
  func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    if !isDisplayingCategories {
      let action  = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
        
        FirebaseUtility.shared.delete(service: self.serviceArray[indexPath.row], completion: { (success, error) in
          
          if let errorMessage = error {
            print(errorMessage)
          } else if success {
            self.getServices()
          }
        })
      }
      //            var markTitle = "Service\nCurrent"
      //            let service = serviceArray[indexPath.row]
      //            if service.serviceStatus {
      //                markTitle = "Service\nNot Current"
      //            }
      //            let markAction = UITableViewRowAction(style: .normal, title: markTitle, handler: { (action, indexPath) in
      //
      //                // Change up to Date
      //
      //            })
      return [action] //, markAction
    }
    return nil
  }
  
}

// MARK: - DZNEmptyDataSet Extension

extension ServiceListViewController: DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
  
  func customView(forEmptyDataSet scrollView: UIScrollView!) -> UIView! {
    let imageView = UIImageView(frame: self.view.frame)
    imageView.image = #imageLiteral(resourceName: "EmptyViewImage")
    imageView.alpha = 0.3
    imageView.contentMode = .scaleAspectFit
    return imageView
  }
  
}



