//
//  CardDetailViewController.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 5/14/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit
import Firebase

class CardDetailViewController: UIViewController {
    
    @IBOutlet weak var leftNavButton: UIBarButtonItem!
    @IBOutlet weak var rightNavButton: UIBarButtonItem!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var serviceNameTextField: UITextField!
    @IBOutlet weak var innerDividerView: UIView!
    @IBOutlet weak var addServiceButton: UIButton!
    @IBOutlet weak var bottomDividerView: UIView!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var editCardButton: UIButton!
    
    var cardID = ""
    var cardNicknameTransfered = ""
    var cardTypeTransfered = ""
    var selectedService: String?
    var serviceCurrent: Bool?
    var serviceName: String?
    var serviceURL: String?
    var attentionInt: Int?
    var serviceFixedBool: Bool?
    var serviceFixedAmount: String?
    var serviceArray: [ServiceClass] = []
    let ref = Database.database().reference()
    let user = Auth.auth().currentUser
    let selectedCard = CardClass()
    var totalArr: [String] = []
    var doubleArray: [Double] = []
    
    //
    
    let margin: CGFloat = 10
    let cellsPerC = 3
    
    //
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        checkIfDataExits()
        addServiceButton.alpha = 0.4
        addServiceButton.isEnabled = false
        collectionView.isUserInteractionEnabled = true
    }
    
    
    // MARK: Nav Bar & View Design
    
    func setNavBar() {
        // Title is in Firebase Methods
        navigationController?.navigationBar.barTintColor = UIColor(red: 108.0/255.0,
                                                                   green: 158.0/255.0,
                                                                   blue: 236.0/255.0,
                                                                   alpha: 1.0)
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white,
                                                                   NSFontAttributeName: UIFont(name: "GillSans-Bold",
                                                                                               size: 20)!]
    }
    
    
    
    
    // MARK: Firebase Methods
    
    func checkIfDataExits() {
        DispatchQueue.main.async {
            self.serviceArray.removeAll()
            self.totalArr.removeAll()
            self.doubleArray.removeAll()
            
            
            self.ref.observe(DataEventType.value, with: { (snapshot) in

                if snapshot.hasChild("services") {
                    self.pullCardData()
                    self.collectionView.reloadData()
                } else {
                    self.collectionView.reloadData()
                    print("no data")
                }
            })
        }
    }
    
    
    func pullCardData() {
        serviceArray.removeAll()
        let cardRef = ref.child("cards")
        
        
        cardRef.observe(DataEventType.value, with: { (snapshot) in
        

            for cards in snapshot.children {
                let allCardIDs = (cards as AnyObject).key as String
                if allCardIDs == self.cardID {
                    let thisCardLocation = cardRef.child(self.cardID)
                    
                    thisCardLocation.observe(DataEventType.value, with: { (snapshot) in
                    
                        let thisCardDetails = snapshot as DataSnapshot
                        let cardDict = thisCardDetails.value as! [String: AnyObject]
                        self.selectedCard.cardID = thisCardDetails.key
                        self.selectedCard.nickname = cardDict["nickname"] as! String
                        print("Hello \(self.selectedCard.nickname)")
                        self.selectedCard.type = cardDict["type"] as! String
                        self.pullServicesForCard()
                    })
                }
            }
        })
    }
    
    
    func pullServicesForCard() {
        let thisCardServices = self.ref.child("cards").child(self.cardID).child("services")
        let serviceRefLoc = self.ref.child("services")
        
        
        thisCardServices.observe(DataEventType.value, with: { (serviceSnap) in
        
            if serviceSnap.hasChildren() {
                for serviceChild in serviceSnap.children {
                    let serviceID = (serviceChild as AnyObject).key as String
                    
                    
                    serviceRefLoc.observe(DataEventType.value, with: { (allServiceSnap) in
                    
                        if allServiceSnap.hasChildren() {
                            for all in allServiceSnap.children {
                                let allServs = (all as AnyObject).key as String
                                let thisServiceLocationInServiceNode = self.ref.child("services").child(serviceID)
                                if serviceID == allServs {
                                    
                                    
                                    thisServiceLocationInServiceNode.observe(DataEventType.value, with: { (thisSnap) in

                                        let serv = thisSnap as DataSnapshot
                                        let serviceDict = serv.value as! [String: AnyObject]
                                        let aService = ServiceClass()
                                        self.serviceCurrent = serviceDict["serviceStatus"] as? Bool
                                        self.serviceName = serviceDict["serviceName"] as? String
                                        self.serviceURL = serviceDict["serviceURL"] as? String
                                        self.serviceFixedBool = serviceDict["serviceFixed"] as? Bool
                                        self.serviceFixedAmount = serviceDict["serviceAmount"] as? String
                                        self.attentionInt = serviceDict["attentionInt"] as? Int
                                        
                                        aService.serviceUrl = serviceDict["serviceURL"] as! String
                                        aService.serviceName = serviceDict["serviceName"] as! String
                                        aService.serviceAmount = serviceDict["serviceAmount"] as! String
                                        aService.serviceStatus = serviceDict["serviceStatus"] as? Bool
                                        aService.serviceAttention = serviceDict["attentionInt"] as! Int
                                        
                                        DispatchQueue.main.async {
                                            self.totalArr.append((serviceDict["serviceAmount"] as? String)!)
                                        }
                                        self.doubleArray = self.totalArr.flatMap{ Double($0) }
                                        let arraySum = self.doubleArray.reduce(0, +)
                                        
                                        self.title = "\(self.selectedCard.nickname): \(arraySum)"
                                        
                                        aService.serviceID = serviceID
                                        if serviceDict["serviceStatus"] as? Bool == true {
                                            self.selectedCard.cStatus = true
                                        } else {
                                            self.selectedCard.cStatus = false
                                        }
                                        DispatchQueue.main.async {
                                            self.serviceArray.append(aService)
                                        }
                                        self.serviceArray.sort {
                                            if $0.serviceAttention == $1.serviceAttention { return $0.serviceName < $1.serviceName }
                                            return $0.serviceAttention > $1.serviceAttention
                                        }
                                        self.delay(0.3, closure: {
                                            DispatchQueue.main.async {
                                                self.collectionView.reloadData()
                                            }
                                        })
                                    })
                                }
                            }
                        }
                    })
                }
            }
        })
    }
    
    
    
    func addServiceToCard() {
        let service = ref.child("services").childByAutoId()
        let serviceBeingAdded = serviceNameTextField.text ?? ""
        let whiteSpacesRemoved = serviceBeingAdded.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).capitalized
        service.setValue(["serviceURL": "", "serviceName": whiteSpacesRemoved, "serviceStatus": true, "serviceFixed": false, "serviceAmount": "", "attentionInt": 0])
        ref.child("cards").child(cardID).child("services").child(service.key).setValue(true)
        pullCardData()
        serviceNameTextField.text = ""
        addServiceButton.alpha = 0.4
        addServiceButton.isEnabled = false
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
    
    
    // MARK: Prepare For Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "fromCardDetailToEditService" {
            if let controller = segue.destination as? UINavigationController {
                if let destinationVC = controller.topViewController as? EditServiceViewController {
                    destinationVC.thisCardTransfered = cardID
                    destinationVC.thisCardNicknameTransfered = cardNicknameTransfered
                    destinationVC.thisCardTypeTransfered = cardTypeTransfered
                    destinationVC.thisServiceTransfered = selectedService!
                    destinationVC.serviceUpToDateTransfered = serviceCurrent
                    destinationVC.serviceNameTransfered = serviceName
                    destinationVC.serviceURLTransfered = serviceURL
                    destinationVC.serviceFixedTransfered = serviceFixedBool
                    destinationVC.serviceAmountTransfered = serviceFixedAmount
                }
            }
        } else if segue.identifier == "fromCardDetailToEditCard" {
            if let controller = segue.destination as? UINavigationController {
                if let destinationVC = controller.topViewController as? EditCardViewController {
                    destinationVC.thisCardIDTransfered = cardID
                }
            }
        }
    }
    
    
    // MARK: IB Actions
    
    @IBAction func leftNavBarButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "fromCardDetailToWallet", sender: self)
    }
    
    @IBAction func rightNavBarButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "fromCardDetailsToPreferences", sender: self)
    }
    
    @IBAction func editCardButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "fromCardDetailsToEditCard", sender: self)
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
    
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        textField.resignFirstResponder()
        return false
    }
    
    
}


// MARK: UITextField Delegate

extension CardDetailViewController: UITextFieldDelegate {
    
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


extension CardDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let screenRect: CGRect = UIScreen.main.bounds
//        let screenWidth: CGFloat = screenRect.size.width
//        let screenHeight: CGFloat = screenRect.size.height
//        let cellWidth: Float = Float(screenWidth / 3.0)
//        let cellHeight: Float = Float(screenHeight / 3.0)
//        let size = CGSize(width: CGFloat(cellWidth), height: CGFloat(cellHeight))
//        return size
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let marginsAndInsets = flowLayout.sectionInset.left + flowLayout.sectionInset.right + flowLayout.minimumInteritemSpacing * CGFloat(cellsPerC - 1)
        let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(cellsPerC)).rounded(.down)
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let padding: CGFloat = 25
//        let collectionCellSize = collectionView.frame.size.width - padding
//        return CGSize(width: collectionCellSize/2, height: collectionCellSize/2)
//    }
    

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return serviceArray.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "serviceCell", for: indexPath as IndexPath) as! ServiceCollectionViewCell
        let row = indexPath.row
        cell.colorStatusView.backgroundColor = .white
        
//        cell.colorStatusView.layer.borderWidth = 5
        if serviceArray[row].serviceStatus == true {
            cell.colorStatusView.backgroundColor = .green
        } else {
            cell.colorStatusView.backgroundColor = .red
        }
        cell.serviceNameLabel.text = serviceArray[row].serviceName
        cell.serviceFixedAmountLabel.text = serviceArray[row].serviceAmount
        
        cell.serviceLogoImage.image = UIImage.init(named: "\(self.getLetterOrNumberAndChooseImage(text: self.serviceArray[row].serviceName))")
        
        DispatchQueue.global(qos: .background).async {
            let myURLString: String = "http://www.google.com/s2/favicons?domain=\(self.serviceArray[row].serviceUrl)"
            DispatchQueue.main.async {
                if let myURL = URL(string: myURLString), let myData = try? Data(contentsOf: myURL), let image = UIImage(data: myData) {
                    cell.serviceLogoImage.image = image
                } else {
                    cell.serviceLogoImage.image = UIImage.init(named: "\(self.getLetterOrNumberAndChooseImage(text: self.serviceArray[row].serviceName))")
                }
                
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            let row = indexPath.row
            self.selectedService = self.serviceArray[row].serviceID as String
            if self.selectedService != "" {
                self.performSegue(withIdentifier: "fromCardDetailToEditService", sender: self)
            }
            collectionView.isUserInteractionEnabled = false
        }
    }
    
}















