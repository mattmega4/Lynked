//
//  ServicesViewController.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 6/20/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit
//import SDWebImage
import Kingfisher
import MBProgressHUD



class ServicesViewController: UIViewController {
    
    @IBOutlet weak var leftNavBarButton: UIBarButtonItem!
    @IBOutlet weak var rightNavBarButton: UIBarButtonItem!
    
    @IBOutlet weak var firstContainerView: UIView!
    @IBOutlet weak var serviceTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    
    @IBOutlet weak var leftVerticalDividerView: UIView!
    @IBOutlet weak var rightVerticalDividerView: UIView!
    @IBOutlet weak var addServiceButton: UIButton!
    
    
    @IBOutlet weak var dividerViewTwo: UIView!
    
    
    @IBOutlet weak var secondContainerView: UIView!
    @IBOutlet weak var segControl: UISegmentedControl!
    
    @IBOutlet weak var disclaimerLabelOne: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var disclaimerLabelTwo: UILabel!
    
    @IBOutlet weak var editCardButton: UIButton!
    
    @IBOutlet weak var dividerViewOne: UIView!
    
    
    let categoryPickerView = UIPickerView()
    let serviceCellId = "ServiceCell"
    let categoryCellId = "CategoryCell"
    var serviceArray = [ServiceClass]()
    var categories = [String]()
    var isDisplayingCategories = false
    var card: CardClass?

    //    let margin: CGFloat = 10
    //    let cellsPerC = 3
    let margin = (UIDevice.current.userInterfaceIdiom == .pad ? 5: 10) as CGFloat
    let cellsPerC = (UIDevice.current.userInterfaceIdiom == .pad ? 4: 3) as CGFloat

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.serviceTextField.delegate = self
        self.categoryTextField.delegate = self
        self.categoryPickerView.delegate = self
        self.categoryPickerView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        collectionView.allowsSelection = true
        setNavBar()
        
        serviceTextField.addTarget(self, action: #selector(enableAddButton(textField:)), for: .editingChanged)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ServicesViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
        guard let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        flowLayout.minimumInteritemSpacing = margin
        flowLayout.minimumLineSpacing = margin
        flowLayout.sectionInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
        
        categoryTextField.inputView = categoryPickerView
        
        title = card?.nickname
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addServiceButton.alpha = 0.4
        addServiceButton.isEnabled = false
        getServices()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        sortArray()
//        showReview()
    }
    
    
    // MARK: - Sort Array
    
    func sortArray() {
        self.serviceArray.sort {
            if $0.serviceAttention == $1.serviceAttention { return $0.serviceName ?? "" < $1.serviceName ?? "" }
            return $0.serviceAttention > $1.serviceAttention
        }
    }
    
    
    // MARK: - Get Services
    
    func getServices() {
        if let theCard = card {
            FirebaseUtility.shared.getServicesFor(card: theCard, completion: { (services, error) in
                if let theServices = services {
                    
                    self.serviceArray = theServices
                    self.getCategories()
                    self.sortArray()
                    
                    self.collectionView.reloadData()
                } else {
                    if let theError = error?.localizedDescription {
                        let errorMessage = theError
                        print(errorMessage)
                    }
                }
            })
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
    
    func addService(service: ServiceClass) {
        serviceArray.append(service)
        sortArray()
    }
    
    
    func addServiceToCard() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        FirebaseUtility.shared.addService(name: serviceTextField.text?.capitalized, forCard: card, withCategory: categoryTextField.text) { (service, errMessage) in
            MBProgressHUD.hide(for: self.view, animated: true)
            if let theService = service {
                self.addService(service: theService)
                
                self.serviceTextField.text = ""
                self.categoryTextField.text = nil
                self.addServiceButton.alpha = 0.4
                self.addServiceButton.isEnabled = false
                self.getCategories()
                self.collectionView.reloadData()
            }
        }
    }
    
    
    // MARK: - IB Actions
    
    @IBAction func leftNavBarButtonTapped(_ sender: UIBarButtonItem) {
        if let walletVC = storyboard?.instantiateViewController(withIdentifier: "WalletVC") as? WalletViewController {
            navigationController?.pushViewController(walletVC, animated: true)
        }
    }
    
    @IBAction func rightNavBarButtonTapped(_ sender: UIBarButtonItem) {
        if let prefVC = storyboard?.instantiateViewController(withIdentifier: "PrefVC") as? PreferencesViewController {
            navigationController?.pushViewController(prefVC, animated: true)
        }
    }
    
    @IBAction func editCardButtonTapped(_ sender: UIButton) {
        if let editCardVC = storyboard?.instantiateViewController(withIdentifier: "EditCardVC") as? EditCardViewController {
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
        collectionView.reloadData()
    }
    
    
    // MARK: - Keyboard Methods
    
    func keyboardWillShow(notification:NSNotification) {
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        var contentInset: UIEdgeInsets = self.collectionView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        self.collectionView.contentInset = contentInset
    }
    
    func keyboardWillHide(notification:NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.collectionView.contentInset = contentInset
    }
}


// MARK: - UIPickerView Delegate & DataSource Methods

extension ServicesViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
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


extension ServicesViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == serviceTextField {
            serviceTextField.returnKeyType = .next
            categoryTextField.becomeFirstResponder()
        } else if textField == categoryTextField {
            textField.returnKeyType = .go
            addServiceToCard()
            view.endEditing(true)
        }
        return false
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == categoryTextField {
            categoryTextField.text = categories[0]
        } else if textField == serviceTextField {
            
        }
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func enableAddButton(textField: UITextField) {
        if (textField.text?.isEmpty)! {
            addServiceButton.isEnabled = false
            addServiceButton.alpha = 0.4
        } else if !(textField.text?.isEmpty)! {
            addServiceButton.isEnabled = true
            addServiceButton.alpha = 1.0
        }
    }
}


// MARK: - UICollectionView Delegate, DataSource, and DelegateFlowLayout Methods

extension ServicesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let marginsAndInsets = flowLayout.sectionInset.left + flowLayout.sectionInset.right + flowLayout.minimumInteritemSpacing * CGFloat(cellsPerC - 1)
        let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(cellsPerC)).rounded(.down)
        
        
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    
    
    
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    //
    //        // How many Cells Wide ------------ 4 for ipad 3 for not ipad
    //        let numberOfCellsWide = (UIDevice.current.userInterfaceIdiom == .pad ? 4: 3) as CGFloat
    //        // Width of the Cell: minus the 1 because I want a 1 px separation of cells.
    //        let width = (collectionView.frame.width/numberOfCellsWide) - 1
    //
    //        return CGSize(width:width, height:width)
    //    }
    
    
    
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !isDisplayingCategories {
            return serviceArray.count
        }
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if !isDisplayingCategories {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: serviceCellId, for: indexPath) as! ServiceCollectionViewCell
            let service = serviceArray[indexPath.row]
            cell.colorStatusView.backgroundColor = service.serviceStatus ? .green : .red
            cell.serviceNameLabel.text = service.serviceName
            cell.serviceFixedAmountLabel.text = String(service.serviceAmount)
            
            let placeholderImage = UIImage.init(named: "\(TempLetterImagePickerUtility.shared.getLetterOrNumberAndChooseImage(text: service.serviceName!))")
            
            if let serviceURLString = service.serviceUrl, service.serviceUrl?.isEmpty == false {
                
                if let imageURL = URL(string: "https://logo.clearbit.com/\(serviceURLString)") {
                    cell.serviceLogoImage.kf.setImage(with: imageURL, placeholder: placeholderImage, options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, url) in
                        if image == nil {
                            let myURLString: String = "http://www.google.com/s2/favicons?domain=\(serviceURLString)"
                            if let myURL = URL(string: myURLString) {
                                cell.serviceLogoImage.kf.setImage(with: myURL, placeholder: placeholderImage)
                            }
                            
                        }
                    })
                }
                return cell
            }
        }
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: categoryCellId, for: indexPath) as! ServiceCategoryCollectionViewCell
        cell.categoryNameLabel.text = categories[indexPath.row]
        let categoryServices = serviceArray.filter({$0.category == categories[indexPath.row]})
        for i in 0..<min(categoryServices.count, 3) {
            let service = categoryServices[i]
            let placeholderImage = UIImage.init(named: "\(TempLetterImagePickerUtility.shared.getLetterOrNumberAndChooseImage(text: service.serviceName!))")
            if let seviceURLString = service.serviceUrl, service.serviceUrl?.isEmpty == false {
                let myURLString: String = "http://www.google.com/s2/favicons?domain=\(seviceURLString)"
                
                if let myURL = URL(string: myURLString) {
                    switch i {
                    case 0:
                        cell.previewImageViewOne.kf.setImage(with: myURL, placeholder: placeholderImage)
                    //                        cell.previewImageViewOne.sd_setImage(with: myURL, placeholderImage: placeholderImage)
                    case 1:
                        cell.previewImageViewTwo.kf.setImage(with: myURL, placeholder: placeholderImage)
                    //                        cell.previewImageViewTwo.sd_setImage(with: myURL, placeholderImage: placeholderImage)
                    case 2:
                        cell.previewImageViewThree.kf.setImage(with: myURL, placeholder: placeholderImage)
                    //                        cell.previewImageViewThree.sd_setImage(with: myURL, placeholderImage: placeholderImage)
                    case 3:
                        cell.previewImageViewFour.kf.setImage(with: myURL, placeholder: placeholderImage)
                        //                        cell.previewImageViewFour.sd_setImage(with: myURL, placeholderImage: placeholderImage)
                        
                    default:
                        print("I shouldn't have been printed")
                    }
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isDisplayingCategories {
            if let serviceDetailVC = storyboard?.instantiateViewController(withIdentifier: "serviceDetailVC") as? ServiceDetailViewController {
                serviceDetailVC.service = self.serviceArray[indexPath.row]
                navigationController?.pushViewController(serviceDetailVC, animated: true)
            }
        }
        else {
            
        }
    }
}















