//
//  CardDetailViewController.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 5/14/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit
import SDWebImage
import MBProgressHUD

class CardDetailViewController: UIViewController {
    
    @IBOutlet weak var leftNavButton: UIBarButtonItem!
    @IBOutlet weak var rightNavButton: UIBarButtonItem!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var serviceNameTextField: UITextField!
    @IBOutlet weak var innerDividerView: UIView!
    @IBOutlet weak var addServiceButton: UIButton!
    @IBOutlet weak var bottomDividerView: UIView!
    
    //    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var editCardButton: UIButton!
    
    var serviceArray: [ServiceClass] = []
    var card: CardClass?
    
    let margin: CGFloat = 10
    let cellsPerC = 3
    
    //    var autoCompletePossibilities: [String] = []
    //    var autoComplete: [String] = []
    //
    //    var countedSet: NSCountedSet?
    //    var dataArray = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        self.tableView.delegate = self
        //        self.tableView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.serviceNameTextField.delegate = self
        
        collectionView.allowsSelection = true
        setNavBar()
        serviceNameTextField.addTarget(self, action: #selector(enableAddButton(textField:)), for: .editingChanged)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CardDetailViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
        guard let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        flowLayout.minimumInteritemSpacing = margin
        flowLayout.minimumLineSpacing = margin
        flowLayout.sectionInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
        
        title = card?.nickname
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        tableView.isHidden = true
        addServiceButton.alpha = 0.4
        addServiceButton.isEnabled = false
        getServices()
    }
    
    func getServices() {
        if let theCard = card {
            FirebaseUtility.shared.getServicesFor(card: theCard, completion: { (services, error) in
                if let theServices = services {
                    self.serviceArray = theServices
                    self.collectionView.reloadData()
                }
                else {
                    // TODO display Error
                }
            })
        }
        else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func addService(service: ServiceClass) {
        serviceArray.append(service)
        self.serviceArray.sort {
            if $0.serviceAttention == $1.serviceAttention { return $0.serviceName ?? "" < $1.serviceName ?? "" }
            return $0.serviceAttention > $1.serviceAttention
        }
    }
    
    
    
    
    // MARK: - Firebase Methods For CollectionView
    
    func addServiceToCard() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        FirebaseUtility.shared.addService(name: serviceNameTextField.text, forCard: card) { (service, errMessage) in
            MBProgressHUD.hide(for: self.view, animated: true)
//            self.tableView.isHidden = true
            if let theService = service {
                self.addService(service: theService)
                
                self.serviceNameTextField.text = ""
                self.addServiceButton.alpha = 0.4
                self.addServiceButton.isEnabled = false
                
                self.collectionView.reloadData()
            }
        }
    }
    
    // MARK: - Set Letter/Number Image For NO URL
    
    func getLetterOrNumberAndChooseImage(text: String) -> String {
        
        if text == " " || text == "" {
            return "*"
        }
        
        let index = text.index(text.startIndex, offsetBy: 0)
        let letterImageToLoad = text[index]
        let letter = String(letterImageToLoad).lowercased()
        let imageName = { () -> String in
            switch letter {
            case "a":
                return "A.png"
            case "b":
                return "B.png"
            case "c":
                return "C.png"
            case "d":
                return "D.png"
            case "e":
                return "E.png"
            case "f":
                return "F.png"
            case "g":
                return "G.png"
            case "h":
                return "H.png"
            case "i":
                return "I.png"
            case "j":
                return "J.png"
            case "k":
                return "K.png"
            case "l":
                return "L.png"
            case "m":
                return "M.png"
            case "n":
                return "N.png"
            case "o":
                return "O.png"
            case "p":
                return "P.png"
            case "q":
                return "Q.png"
            case "r":
                return "R.png"
            case "s":
                return "S.png"
            case "t":
                return "T.png"
            case "u":
                return "U.png"
            case "v":
                return "V.png"
            case "w":
                return "W.png"
            case "x":
                return "X.png"
            case "y":
                return "Y.png"
            case "z":
                return "Z.png"
            case "0":
                return "Zero.png"
            case "1":
                return "One.png"
            case "2":
                return "Two.png"
            case "3":
                return "Three.png"
            case "4":
                return "Four.png"
            case "5":
                return "Five.png"
            case "6":
                return "Six.png"
            case "7":
                return "Seven.png"
            case "8":
                return "Eight.png"
            case "9":
                return "Nine.png"
            default:
                return "Star.png"
            }
        }()
        return imageName
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


// MARK: - UITextField Delegate

extension CardDetailViewController: UITextFieldDelegate {
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == serviceNameTextField {
            
            serviceNameTextField.returnKeyType = .go
            addServiceToCard()
            view.endEditing(true)
//            tableView.isHidden = true
//            collectionView.isUserInteractionEnabled = true
        }
        
        return false
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func enableAddButton(textField: UITextField) {
        if (textField.text?.isEmpty)! {
            addServiceButton.isEnabled = false
            addServiceButton.alpha = 0.4
//            tableView.isHidden = true
//            collectionView.isUserInteractionEnabled = true
        } else if !(textField.text?.isEmpty)! {
            addServiceButton.isEnabled = true
            addServiceButton.alpha = 1.0
//            tableView.isHidden = false
            //collectionView.isUserInteractionEnabled = false
        }
    }
}


extension CardDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return serviceArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let marginsAndInsets = flowLayout.sectionInset.left + flowLayout.sectionInset.right + flowLayout.minimumInteritemSpacing * CGFloat(cellsPerC - 1)
        let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(cellsPerC)).rounded(.down)
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "serviceCell", for: indexPath as IndexPath) as! ServiceCollectionViewCell
        let row = indexPath.row
        cell.colorStatusView.backgroundColor = .white
        
        if serviceArray[row].serviceStatus == true {
            cell.colorStatusView.backgroundColor = .green
        } else {
            cell.colorStatusView.backgroundColor = .red
        }
        cell.serviceNameLabel.text = serviceArray[row].serviceName
        cell.serviceFixedAmountLabel.text = "\(serviceArray[row].serviceAmount)"
        
        let placeholderImage = UIImage.init(named: "\(self.getLetterOrNumberAndChooseImage(text: self.serviceArray[row].serviceName!))")
        if let seviceURLString = self.serviceArray[row].serviceUrl, self.serviceArray[row].serviceUrl?.isEmpty == false {
            let myURLString: String = "http://www.google.com/s2/favicons?domain=\(seviceURLString)"
            
            if let myURL = URL(string: myURLString) {
                cell.serviceLogoImage.sd_setImage(with: myURL, placeholderImage: placeholderImage)
            }
        }
            
        else {
            cell.serviceLogoImage.image = placeholderImage
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = indexPath.row
        let service = self.serviceArray[row]
        if let editServiceVC = self.storyboard?.instantiateViewController(withIdentifier: "EditServiceVC") as? EditServiceViewController {
            editServiceVC.service = service
            self.navigationController?.pushViewController(editServiceVC, animated: true)
            
        }
    }
    
}












