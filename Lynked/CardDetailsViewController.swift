//
//  CardDetailsViewController.swift
//  Lynked
//
//  Created by Matthew Singleton on 12/11/16.
//  Copyright © 2016 Matthew Singleton. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase


class CardDetailsViewController: UIViewController {
  
  @IBOutlet weak var leftNavBarButton: UIBarButtonItem!
  @IBOutlet weak var rightNavBarButton: UIBarButtonItem!
  @IBOutlet weak var cardNameContainerView: UIView!
  @IBOutlet weak var cardNickNameLabel: UILabel!
  @IBOutlet weak var editCardButton: UIButton!
  @IBOutlet weak var firstDividerView: UIView!
  @IBOutlet weak var addServiceContainerView: UIView!
  @IBOutlet weak var serviceNameLabel: UILabel!
  @IBOutlet weak var serviceNameTextField: UITextField!
  @IBOutlet weak var addServiceButtonContainerView: UIView!
  @IBOutlet weak var addServiceButton: UIButton!
  @IBOutlet weak var secondDividerView: UIView!
  @IBOutlet weak var disclaimerLabel: UILabel!
  @IBOutlet weak var tableView: UITableView!
  
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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.tableView.delegate = self
    self.tableView.dataSource = self
    self.serviceNameTextField.delegate = self
    tableView.allowsSelection = true
    setNavBar()
    serviceNameTextField.addTarget(self, action: #selector(enableAddButton(textField:)), for: .editingChanged)
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CardDetailsViewController.dismissKeyboard))
    view.addGestureRecognizer(tap)
    tap.cancelsTouchesInView = false
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    checkIfDataExits()
    addServiceButton.alpha = 0.4
    addServiceButton.isEnabled = false
    tableView.isUserInteractionEnabled = true
  }
  
  
  // MARK: Nav Bar & View Design
  
  func setNavBar() {
    title = "Card Details"
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
      self.ref.observeSingleEvent(of: .value, with: { snapshot in
        if snapshot.hasChild("services") {
          self.pullCardData()
        } else {
          self.tableView.reloadData()
        }
      })
    }
  }
  
  
  func pullCardData() {
    serviceArray.removeAll()
    let cardRef = ref.child("cards")
    cardRef.observeSingleEvent(of: .value, with: { snapshot in
      for cards in snapshot.children {
        let allCardIDs = (cards as AnyObject).key as String
        if allCardIDs == self.cardID {
          let thisCardLocation = cardRef.child(self.cardID)
          thisCardLocation.observeSingleEvent(of: .value, with: { snapshot in
            let thisCardDetails = snapshot as DataSnapshot
            let cardDict = thisCardDetails.value as! [String: AnyObject]
            self.selectedCard.cardID = thisCardDetails.key
            self.selectedCard.nickname = cardDict["nickname"] as! String
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
    thisCardServices.observeSingleEvent(of: .value, with: {serviceSnap in
      if serviceSnap.hasChildren() {
        for serviceChild in serviceSnap.children {
          let serviceID = (serviceChild as AnyObject).key as String
          serviceRefLoc.observeSingleEvent(of: .value, with: {allServiceSnap in
            if allServiceSnap.hasChildren() {
              for all in allServiceSnap.children {
                let allServs = (all as AnyObject).key as String
                let thisServiceLocationInServiceNode = self.ref.child("services").child(serviceID)
                if serviceID == allServs {
                  thisServiceLocationInServiceNode.observeSingleEvent(of: .value, with: {thisSnap in
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
                    aService.serviceStatus = serviceDict["serviceStatus"] as? Bool
                    aService.serviceAttention = serviceDict["attentionInt"] as! Int
                    
                    DispatchQueue.main.async {
                      self.totalArr.append((serviceDict["serviceAmount"] as? String)!)
                    }
                    self.doubleArray = self.totalArr.flatMap{ Double($0) }
                    let arraySum = self.doubleArray.reduce(0, +)
                    self.cardNickNameLabel.text = "\(self.selectedCard.nickname) Fixed Expense is $\(arraySum)"
                    
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
                        self.tableView.reloadData()
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
  
  
  // MARK: IB Actions
  
  @IBAction func leftNavBarButtonTapped(_ sender: UIBarButtonItem) {
    performSegue(withIdentifier: "fromCardDetailsToLandingPage", sender: self)
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
  
  
  // MARK: Prepare For Segue
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    if segue.identifier == "fromCardDetailsToEditService" {
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
    } else if segue.identifier == "fromCardDetailsToEditCard" {
      if let controller = segue.destination as? UINavigationController {
        if let destinationVC = controller.topViewController as? EditCardViewController {
          destinationVC.thisCardIDTransfered = cardID
        }
      }
    }
  }
  
  
  // MARK: Keyboard Methods
  
  func keyboardWillShow(notification:NSNotification) {
    var userInfo = notification.userInfo!
    var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
    keyboardFrame = self.view.convert(keyboardFrame, from: nil)
    var contentInset: UIEdgeInsets = self.tableView.contentInset
    contentInset.bottom = keyboardFrame.size.height
    self.tableView.contentInset = contentInset
  }
  
  
  func keyboardWillHide(notification:NSNotification) {
    let contentInset:UIEdgeInsets = UIEdgeInsets.zero
    self.tableView.contentInset = contentInset
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
  
  
} // end of CardDetailsViewController Class


// MARK: UITextField Delegate

extension CardDetailsViewController: UITextFieldDelegate {
  
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


//MARK: UITableViewDataSource Methods

extension CardDetailsViewController: UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return serviceArray.count
  }
  
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "serviceCell", for: indexPath as IndexPath) as! ServiceTableViewCell
    let row = indexPath.row
    cell.serviceStatusView.createRoundView()
    if serviceArray[row].serviceStatus == true {
      cell.serviceStatusView.backgroundColor = .green
    } else {
      cell.serviceStatusView.backgroundColor = .red
    }
    cell.serviceNameLabel.text = serviceArray[row].serviceName
    
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
}


// MARK: UITableViewDelegate Methods

extension CardDetailsViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 40.0
  }
  
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    DispatchQueue.main.async {
      let row = indexPath.row
      self.selectedService = self.serviceArray[row].serviceID as String
      if self.selectedService != "" {
        self.performSegue(withIdentifier: "fromCardDetailsToEditService", sender: self)
      }
      tableView.isUserInteractionEnabled = false
    }
  }
  
}



