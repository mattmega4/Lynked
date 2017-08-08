//
//  WalletViewController.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 5/31/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit
import StoreKit
import MBProgressHUD
import Firebase
//import SCPinViewController

class WalletViewController: UIViewController {
  
  @IBOutlet weak var rightNavButton: UIBarButtonItem!
  @IBOutlet weak var tableView: UITableView!
  
  var selectedCard: String?
  var cardNicknameToTransfer: String?
  var card4ToTransfer: String?
  var cardtypeToTransfer: String?
  var cardArray: [Card] = []
  var ref: DatabaseReference!
  
  var delegate: WalletViewControllerDelegate?
  
  let CARD_CELL_IDENTIFIER = "cardCell"
  let NEW_CARD_CELL_IDENTIFIER = "newCell"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.tableView.delegate = self
    self.tableView.dataSource = self
    
    title = "Wallet"
    setNavBar()
    //        FirebaseUtility.shared.getAllServices { (services, error) in }
    
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 500
    self.splitViewController?.preferredDisplayMode = .allVisible
    self.navigationItem.setHidesBackButton(true, animated: true)
    ref = Database.database().reference()
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    FirebaseUtility.shared.getAllServices { (services, error) in }
    checkAuthAndPull()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    ref.child("newCards").removeAllObservers()
  }
  
  
  // MARK: - Firebase
  
  func checkAuthAndPull() {
    self.cardArray.removeAll()
    self.tableView.reloadData()
    if Auth.auth().currentUser == nil {
      cardArray.removeAll()
      self.tableView.reloadData()
      if let loginVc = storyboard?.instantiateViewController(withIdentifier: ENTRY_STORYBOARD_IDENTIFIER) as? EntryViewController {
        let loginNavigation = UINavigationController(rootViewController: loginVc)
        self.splitViewController?.present(loginNavigation, animated: true, completion: nil)
      }
    } else {
      pullAllUsersCards()
    }
  }
  
  func pullAllUsersCards() {
    
    FirebaseUtility.shared.getCards { (cards, errMessage) in
      if let theCards = cards {
        if theCards.count < 1 {
          if let addVC = self.storyboard?.instantiateViewController(withIdentifier: ADD_CARD_STORYBOARD_IDENTIFIER) as? AddCardViewController {
            let addNavigation = UINavigationController(rootViewController: addVC)
            if UIDevice.current.userInterfaceIdiom == .pad {
              self.splitViewController?.present(addNavigation, animated: true, completion: nil)
            }
            else {
              self.present(addNavigation, animated: true, completion: nil)
            }
          }
        } else {
          MBProgressHUD.showAdded(to: self.view, animated: true)
          self.cardArray = theCards
          self.tableView.reloadData()
          MBProgressHUD.hide(for: self.view, animated: true)
        }
      }
    }
  }
  
  
  // MARK: - In App Purchase
  
  func navigateAfterPurchaseOrRestore() {
    if let addCardVC = self.storyboard?.instantiateViewController(withIdentifier: ADD_CARD_STORYBOARD_IDENTIFIER) as? AddCardViewController {
      
      let addNavigation = UINavigationController(rootViewController: addCardVC)
      
      if UIDevice.current.userInterfaceIdiom == .pad {
        self.splitViewController?.present(addNavigation, animated: true, completion: nil)
      } else {
        self.navigationController?.present(addNavigation, animated: true, completion: nil)
      }
    }
    
  }
  
  func purchaseProduct() {
    InAppPurchaseUtility.shared.purchaseProduct { (success, error) in
      if success {
        self.navigateAfterPurchaseOrRestore()
      } else  {
        self.showAlertWith(title: "Purchase Failed!", message: error?.localizedDescription)
      }
    }
  }
  
  func restorePurchase() {
    InAppPurchaseUtility.shared.restorePurchase { (success, error) in
      if success {
        self.navigateAfterPurchaseOrRestore()
      } else  {
        self.showAlertWith(title: "Purchase Failed!", message: error?.localizedDescription)
      }
    }
  }
  
  // MARK: - Notification Center
  
  func loadList(){
    pullAllUsersCards()
  }
  
  
  // MARK: - IB Actions
  
  @IBAction func backFromDetail(segue: UIStoryboardSegue) {
    print("back")
  }
  
  
  @IBAction func rightBarButtonTapped(_ sender: UIBarButtonItem) {
    if let prefVC = self.storyboard?.instantiateViewController(withIdentifier: PROFILE_STORYBOARD_IDENTIFIER) as? ProfileViewController {
      let prefNavigation = UINavigationController(rootViewController: prefVC)
      self.splitViewController?.present(prefNavigation, animated: true, completion: nil)
    }
    
  }
  

}


// MARK: - TableView Delegate & Data Source Methods

extension WalletViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    if indexPath.row == 0 {
      
      if InAppPurchaseUtility.shared.isPurchased {
        if let addCardVC = self.storyboard?.instantiateViewController(withIdentifier: ADD_CARD_STORYBOARD_IDENTIFIER) as? AddCardViewController {
          //          self.navigationController?.pushViewController(addCardVC, animated: true)
          self.navigationController?.present(addCardVC, animated: true, completion: nil)
        }
      } else {
        let actionSheet = UIAlertController(title: nil, message: "You will need to purchase this to add more than 1 card", preferredStyle: .actionSheet)
        let purchaseAction = UIAlertAction(title: "Purchase", style: .default, handler: { (action) in
          self.purchaseProduct()
        })
        let restoreAction = UIAlertAction(title: "Restore", style: .default, handler: { (action) in
          self.restorePurchase()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(purchaseAction)
        actionSheet.addAction(restoreAction)
        actionSheet.addAction(cancelAction)
        actionSheet.popoverPresentationController?.sourceView = tableView.cellForRow(at: indexPath)
        present(actionSheet, animated: true, completion: nil)
      }
      return
    }
    
    DispatchQueue.main.async {
      let row = indexPath.row - 1
      self.selectedCard = self.cardArray[row].cardID
      if self.selectedCard != "" {
        if let cardDVC = self.storyboard?.instantiateViewController(withIdentifier: SERVICES_STORYBOARD_IDENTIFIER) as? ServiceListViewController {
          
          if let cell = tableView.cellForRow(at: indexPath) as? CardTableViewCell {
            cell.cardBorderView.backgroundColor = .orange
          }
          
          cardDVC.card = self.cardArray[indexPath.row - 1]
          
          let serviceNavigation = UINavigationController(rootViewController: cardDVC)
          self.splitViewController?.showDetailViewController(serviceNavigation, sender: self)
          
        }
      }
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    if indexPath.row == 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: NEW_CARD_CELL_IDENTIFIER, for: indexPath)
      
      return cell
      
    }
    
    let cell = tableView.dequeueReusableCell(withIdentifier: CARD_CELL_IDENTIFIER, for: indexPath as IndexPath) as! CardTableViewCell
    let row = indexPath.row - 1
    
    
    print(cardArray)
    
    
    if let img = cardArray[row].image {
      cell.cardBackgroundImage.image = img
    }
    
    
    
    cell.cardNicknameLabel.text = cardArray[row].nickname
    cell.cardNicknameLabel.font = cell.cardNicknameLabel.font.withSize((UIDevice.current.userInterfaceIdiom == .pad ? 38 : 16))
    cell.cardNicknameLabel.textColor = cardArray[row].textColor
    
    
    cell.cardDetailsLabel.text =  "\(String(describing: cardArray[row].fourDigits ?? ""))"
    cell.cardDetailsLabel.textColor = cardArray[row].textColor
    cell.cardDetailsLabel.font = cell.cardDetailsLabel.font.withSize((UIDevice.current.userInterfaceIdiom == .pad ? 32 : 14))
    
    
    cell.cardTypeLabel.text = "\(String(describing: cardArray[row].type ?? ""))"
    cell.cardTypeLabel.textColor = cardArray[row].textColor
    cell.cardTypeLabel.font = cell.cardDetailsLabel.font.withSize((UIDevice.current.userInterfaceIdiom == .pad ? 32 : 14))
    
    return cell
    
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return cardArray.count + 1
  }
  
}



extension WalletViewController: UISplitViewControllerDelegate {
  
  override func collapseSecondaryViewController(_ secondaryViewController: UIViewController, for splitViewController: UISplitViewController) {
  }
  
  func splitViewController(_ splitViewController: UISplitViewController, showDetail vc: UIViewController, sender: Any?) -> Bool {
    if let theVC = vc as? ServiceListViewController {
      if theVC.card != nil {
        return true
      }
    }
    return false
  }
  
  func splitViewController(_ splitViewController: UISplitViewController, show vc: UIViewController, sender: Any?) -> Bool {
    return true
  }
  
}

protocol WalletViewControllerDelegate {
  func walletViewController(controller: WalletViewController, didSelectCard card: Card)
}






