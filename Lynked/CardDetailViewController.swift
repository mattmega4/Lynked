//
//  CardDetailViewController.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 5/14/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit
import Firebase
import FirebasePerformance
import Fabric
import Crashlytics
import SDWebImage

class CardDetailViewController: UIViewController {
    
    @IBOutlet weak var leftNavButton: UIBarButtonItem!
    @IBOutlet weak var rightNavButton: UIBarButtonItem!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var serviceNameTextField: UITextField!
    @IBOutlet weak var innerDividerView: UIView!
    @IBOutlet weak var addServiceButton: UIButton!
    @IBOutlet weak var bottomDividerView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var editCardButton: UIButton!
    
    var cardID: String?
    var cardNicknameTransfered = ""
    var cardLast4Transfered = ""
    var cardTypeTransfered = ""
    var selectedService: String?
    var serviceCurrent: Bool?
    var serviceName: String?
    var serviceURL: String?
    var attentionInt: Int?
    var serviceFixedBool: Bool?
    var serviceFixedAmount: String?
    var serviceArray: [ServiceClass] = []
    var tempServiceArray = [ServiceClass]()
    let ref = Database.database().reference()
    let user = Auth.auth().currentUser
    var selectedCard: CardClass?
    var totalArr: [String] = []
    var doubleArray: [Double] = []
    var tempDoubleArray = [Double]()
    
    let margin: CGFloat = 10
    let cellsPerC = 3
    
    
    var autoCompletePossibilities: [String] = []
    var autoComplete: [String] = []
    
    var countedSet: NSCountedSet?
    var dataArray = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.isHidden = true
        collectionView.isUserInteractionEnabled = true
        checkIfDataExits()
        getListOfAllServicesFromFirebase()
        addServiceButton.alpha = 0.4
        addServiceButton.isEnabled = false
        collectionView.isUserInteractionEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        ref.removeAllObservers()
    }
    
    
    // MARK: Nav Bar & View Design
    
    func setNavBar() {
        self.navigationController?.isNavigationBarHidden = false
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
    
    
    // MARK: Predictive Text FOr TableView Logic
    
    func getListOfAllServicesFromFirebase() {
        DispatchQueue.global().async {
            let servicesRef = self.ref.child("services")
            servicesRef.observe( .value, with: { (snapshot) in
                for services in snapshot.children {
                    let allServiceIDs = (services as AnyObject).key as String
                    let serviceDrilled = servicesRef.child(allServiceIDs)
                    serviceDrilled.observeSingleEvent(of: .value, with: { (snap) in
                        let sD = snap as DataSnapshot
                        if let serviceDict = sD.value as? [String: AnyObject] {
                            let aService = ServiceClass(serviceDict: serviceDict)
                            self.serviceArray.append(aService)
                            if let sName = serviceDict["serviceName"] as? String {
                                self.autoCompletePossibilities.append(sName.lowercased())
                            }
                        }
                    })
                }
            })
        }
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == serviceNameTextField {
            let substring = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            searchAutocompleteEntriesWithSubstring(substring)
        }
        return true
    }
    
    
    func searchAutocompleteEntriesWithSubstring(_ substring: String) {
        autoComplete.removeAll(keepingCapacity: false)
        for key in autoCompletePossibilities {
            let myString:NSString! = key as NSString
            let substringRange :NSRange! = myString.range(of: substring)
            if (substringRange.location  == 0) {
                
                autoComplete.append(key)
                self.countedSet = NSCountedSet(array: self.autoComplete)
                self.dataArray = self.countedSet?.allObjects as! [String]
            }
            
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: Firebase Methods For CollectionView
    
    func checkIfDataExits() {
        self.ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild("services") {
                self.pullCardData()
            } else {
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        })
    }
    
    
    func pullCardData() {
        let cardRef = self.ref.child("cards")
        cardRef.observeSingleEvent(of: .value, with: { (snapshot) in
            for cards in snapshot.children {
                let allCardIDs = (cards as AnyObject).key as String
                if allCardIDs == self.cardID {
                    if let childId = self.cardID {
                        let thisCardLocation = cardRef.child(childId)
                        thisCardLocation.observe(DataEventType.value, with: { (snapshot) in
                            let thisCardDetails = snapshot as DataSnapshot
                            if let cardDict = thisCardDetails.value as? [String: AnyObject] {
                                self.selectedCard = CardClass(cardDict: cardDict)
                                if let titleName = self.selectedCard?.nickname {
                                    self.title = "\(titleName)"
                                }
                                self.pullServicesForCard()
                            }
                        })
                    }
                }
            }
        })
    }
    
    func pullServicesForCard() {
        if let theId = self.cardID {
            let thisCardServices = self.ref.child("cards").child(theId).child("services")
            thisCardServices.observeSingleEvent(of: .value, with: { (serviceSnap) in
                if self.serviceArray.count != Int(serviceSnap.childrenCount) {
                    //let servicesTrace = Performance.startTrace(name: "PullServicesTrace")
                    //                    self.serviceArray.removeAll()
                    //                    self.doubleArray.removeAll()
                    self.tempServiceArray.removeAll()
                    self.tempDoubleArray.removeAll()
                    
                    self.fetchAndAddAllServices(serviceSnap: serviceSnap, index: 0, completion: { (success) in
                        if success {
                            DispatchQueue.main.async {
                                self.collectionView.reloadData()
                                //servicesTrace?.stop()
                                
                            }
                        }
                    })
                }
            })
        }
    }
    
    func fetchAndAddAllServices(serviceSnap: DataSnapshot, index: Int, completion: @escaping (_ success: Bool) -> Void) {
        DispatchQueue.global().async {
            if serviceSnap.hasChildren() {
                if index < serviceSnap.children.allObjects.count {
                    let serviceChild = serviceSnap.children.allObjects[index]
                    let serviceID = (serviceChild as AnyObject).key as String
                    
                    let thisServiceLocationInServiceNode = self.ref.child("services").child(serviceID)
                    
                    thisServiceLocationInServiceNode.observeSingleEvent(of: DataEventType.value, with: { (thisSnap) in
                        let serv = thisSnap as DataSnapshot
                        
                        if let serviceDict = serv.value as? [String: AnyObject] {
                            
                            let aService = ServiceClass(serviceDict: serviceDict)
                            self.serviceCurrent = serviceDict["serviceStatus"] as? Bool
                            self.serviceName = serviceDict["serviceName"] as? String ?? ""
                            self.serviceURL = serviceDict["serviceURL"] as? String ?? ""
                            self.serviceFixedBool = serviceDict["serviceFixed"] as? Bool
                            self.serviceFixedAmount = serviceDict["serviceAmount"] as? String ?? ""
                            self.attentionInt = serviceDict["attentionInt"] as? Int
                            //                            self.totalArr.append((serviceDict["serviceAmount"] as? String)!)
                            
                            
                            //                        self.doubleArray = self.totalArr.flatMap{ Double($0) }
                            //                        let arraySum = self.doubleArray.reduce(0, +)
                            //                        self.title = self.selectedCard?.nickname ?? ""
                            
                            if let titleName = self.selectedCard?.nickname {
                                self.title = "\(titleName)"
                            }
                            
                            aService.serviceID = serviceID
                            
                            
                            if !self.tempServiceArray.contains(where: { (service) -> Bool in
                                return service.serviceID == aService.serviceID
                            }) {
                                self.tempServiceArray.append(aService)
                                
                                self.tempServiceArray.sort {
                                    if $0.serviceAttention == $1.serviceAttention { return $0.serviceName ?? "" < $1.serviceName ?? "" }
                                    return $0.serviceAttention > $1.serviceAttention
                                }
                                
                                
                            }
                        }
                        self.fetchAndAddAllServices(serviceSnap: serviceSnap, index: index + 1, completion: completion)
                    })
                    
                }
                else {
                    self.serviceArray = self.tempServiceArray
                    completion(true)
                }
            }
            else {
                completion(false)
            }
            
        }
        
    }
    
    
    func addServiceToCard() {
        collectionView.isUserInteractionEnabled = false
        let service = ref.child("services").childByAutoId()
        let whiteSpacesRemoved = serviceNameTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).capitalized
        
        
        if let tempName = whiteSpacesRemoved {
            
            DispatchQueue.global().async {
                
                let outerTrim = tempName.trimmingCharacters(in: .whitespaces)
                let fullTrim = outerTrim.removingWhitespaces()
                let urlForFirebase = "\(fullTrim).com"
                print(urlForFirebase)
                print("foo")
                
                service.setValue(["serviceURL": urlForFirebase, "serviceName": tempName, "serviceStatus": true, "serviceFixed": false, "serviceAmount": "", "attentionInt": 0], withCompletionBlock: { (error, DatabaseReference) in
                    
                    if error == nil {
                        
                        if let theId = self.cardID {
                            self.ref.child("cards").child(theId).child("services").child(service.key).setValue(true)
                        }
                        
                        self.tableView.isHidden = true
                        self.collectionView.isUserInteractionEnabled = true
                        self.collectionView.reloadData()
                        self.checkIfDataExits()
                    }
                })
            }
        }
        
        
        serviceNameTextField.text = ""
        addServiceButton.alpha = 0.4
        addServiceButton.isEnabled = false
        
        Analytics.logEvent("Service_Quick_Add", parameters: ["success" : true])
        
        Answers.logCustomEvent(withName: "Service Quick Add",
                               customAttributes: nil)
        
    }
    
    
    // MARK: Set Letter/Number Image For NO URL
    
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
    
    
    
    // MARK: IB Actions
    
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
            if let theId = cardID {
                editCardVC.thisCardIDTransfered = theId
            }
            navigationController?.pushViewController(editCardVC, animated: true)
        }
    }
    
    @IBAction func addServiceButtonTapped(_ sender: UIButton) {
        addServiceToCard()
    }
    
    
    // MARK: Keyboard Methods
    
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
    
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
}


// MARK: UITextField Delegate

extension CardDetailViewController: UITextFieldDelegate {
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == serviceNameTextField {
            
            serviceNameTextField.returnKeyType = .go
            addServiceToCard()
            view.endEditing(true)
            tableView.isHidden = true
            collectionView.isUserInteractionEnabled = true
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
            tableView.isHidden = true
            collectionView.isUserInteractionEnabled = true
        } else if !(textField.text?.isEmpty)! {
            addServiceButton.isEnabled = true
            addServiceButton.alpha = 1.0
            tableView.isHidden = false
            collectionView.isUserInteractionEnabled = false
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
        cell.serviceFixedAmountLabel.text = serviceArray[row].serviceAmount
        
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
        self.selectedService = self.serviceArray[row].serviceID!
        if self.selectedService != "" {
            
            if let editServiceVC = self.storyboard?.instantiateViewController(withIdentifier: "EditServiceVC") as? EditServiceViewController {
                
                
                editServiceVC.thisCardTransfered = self.cardID ?? ""
                editServiceVC.thisCardNicknameTransfered = self.cardNicknameTransfered
                editServiceVC.thisCardTypeTransfered = self.cardTypeTransfered
                editServiceVC.thisServiceTransfered = self.selectedService!
                editServiceVC.serviceUpToDateTransfered = self.serviceCurrent
                editServiceVC.serviceNameTransfered = self.serviceName
                editServiceVC.serviceURLTransfered = self.serviceURL
                editServiceVC.serviceFixedTransfered = self.serviceFixedBool
                editServiceVC.serviceAmountTransfered = self.serviceFixedAmount
                
                self.navigationController?.pushViewController(editServiceVC, animated: true)
                
            }
        }
        collectionView.isUserInteractionEnabled = false
    }
    
}


extension CardDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "autoComCell", for: indexPath) as! AutoCompleteTableViewCell
        let item = dataArray[indexPath.row]
        
        cell.previewNameLabel.text = item
        
        let myURLString: String = "http://www.google.com/s2/favicons?domain=www.\(item.removingWhitespaces()).com"
        if let myURL = URL(string: myURLString) {
            cell.previewImageView.sd_setImage(with: myURL, placeholderImage: #imageLiteral(resourceName: "Ly"))
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedCell: AutoCompleteTableViewCell = tableView.cellForRow(at: indexPath)! as! AutoCompleteTableViewCell
        
        serviceNameTextField.text = selectedCell.previewNameLabel.text
        
        tableView.isHidden = true
        collectionView.isUserInteractionEnabled = true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 34.0
    }
    
}













