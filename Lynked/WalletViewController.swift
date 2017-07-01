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

class WalletViewController: UIViewController {
    
    @IBOutlet weak var rightNavButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    var selectedCard: String?
    var cardNicknameToTransfer: String?
    var card4ToTransfer: String?
    var cardtypeToTransfer: String?
    var cardArray: [CardClass] = []
    var delegate: WalletViewControllerDelegate?
    
    let cardCellIdentifier = "cardCell"
    let newCardCellIdentifier = "newCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        title = "Wallet"
        setNavBar()
        pullAllUsersCards()
        FirebaseUtility.shared.getAllServices { (services, error) in }
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 500
        self.splitViewController?.preferredDisplayMode = .allVisible
        //self.splitViewController?.displayMode =
        self.navigationItem.setHidesBackButton(true, animated: true)
        // self.splitViewController?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //        pullAllUsersCards()
        tableView.isUserInteractionEnabled = true
    }
    
    func pullAllUsersCards() {
        MBProgressHUD.showAdded(to: view, animated: true)
        FirebaseUtility.shared.getCards { (cards, errMessage) in
            
            MBProgressHUD.hide(for: self.view, animated: true)
            if let theCards = cards {
                if theCards.count < 1 {
                    if let addVC = self.storyboard?.instantiateViewController(withIdentifier: ADD_CARD_STORYBOARD_IDENTIFIER) as? AddCardViewController {
                        self.navigationController?.pushViewController(addVC, animated: true)
                    }
                }
                else {
                    self.cardArray = theCards
                    self.tableView.reloadData()
                }
            }
            else {
                // TODO: - Display error
            }
        }
    }
    
    
    // MARK: - Prepare For Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let selectedRow = tableView.indexPathForSelectedRow {
            let card = cardArray[selectedRow.row]
            if let walletDetailVC = segue.destination as? ServicesViewController {
                walletDetailVC.card = card
            }
        }
    }
    
    
    // MARK: - IB Actions
    
    @IBAction func leftBarButtonTapped(_ sender: UIBarButtonItem) {
        
    }
    
    
    @IBAction func rightBarButtonTapped(_ sender: UIBarButtonItem) {
        if let prefVC = self.storyboard?.instantiateViewController(withIdentifier: PREFERENCES_STORYBOARD_IDENTIFIER) as? PreferencesViewController {
            self.navigationController?.pushViewController(prefVC, animated: true)
        }
        
    }
    
    func purchaseProduct() {
        InAppPurchaseUtility.shared.purchaseProduct { (success, error) in
            if success {
                if let addCardVC = self.storyboard?.instantiateViewController(withIdentifier: ADD_CARD_STORYBOARD_IDENTIFIER) as? AddCardViewController {
                    self.navigationController?.pushViewController(addCardVC, animated: true)
                }
            }
            else  {
                self.showAlertWith(title: "Purchase Failed!", message: error?.localizedDescription)
            }
        }
    }
    
    func restorePurchase() {
        InAppPurchaseUtility.shared.restorePurchase { (success, error) in
            if success {
                if let addCardVC = self.storyboard?.instantiateViewController(withIdentifier: ADD_CARD_STORYBOARD_IDENTIFIER) as? AddCardViewController {
                    self.navigationController?.pushViewController(addCardVC, animated: true)
                }
            }
            else  {
                self.showAlertWith(title: "Purchase Failed!", message: error?.localizedDescription)
            }
        }
    }
} // MARK: - End of WalletViewController


// MARK: - TableView Delegate & Data Source Methods

extension WalletViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (UIDevice.current.userInterfaceIdiom == .pad ? 279 : 127) as CGFloat
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            
            
            if InAppPurchaseUtility.shared.isPurchased {
                if let addCardVC = self.storyboard?.instantiateViewController(withIdentifier: ADD_CARD_STORYBOARD_IDENTIFIER) as? AddCardViewController {
                    self.navigationController?.pushViewController(addCardVC, animated: true)
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
                if let cardDVC = self.storyboard?.instantiateViewController(withIdentifier: SERVICES_STORYBOARD_IDENTIFIER) as? ServicesViewController {
                    
                    
                    if let cell = tableView.cellForRow(at: indexPath) as? CardTableViewCell {
                        cell.cardBorderView.backgroundColor = .orange
                    }
                    
                    
                    //delegate?.walletViewController(controller: self, didSelectCard: self.selectedCard)
                    
                    
                    cardDVC.card = self.cardArray[indexPath.row]
                    let serviceNavigation = UINavigationController(rootViewController: cardDVC)
                    self.splitViewController?.showDetailViewController(serviceNavigation, sender: self)
                    
                    
                    //(parent?.parent as? UISplitViewController)?.showDetailViewController(cardDVC, sender: self)
                    
                    //                    self.navigationController?.pushViewController(cardDVC, animated: true)
                }
            }
            tableView.isUserInteractionEnabled = false
        }
        // was a card
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: newCardCellIdentifier, for: indexPath)
            
            return cell
            
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cardCellIdentifier, for: indexPath as IndexPath) as! CardTableViewCell
        let row = indexPath.row - 1
        
        
        if cell.isSelected {
            cell.cardBorderView.backgroundColor = .orange
            cell.cardBackgroundView.backgroundColor = cardArray[row].color
        } else {
            cell.cardBorderView.backgroundColor = .darkGray
            cell.cardBackgroundView.backgroundColor = cardArray[row].color
        }
        
        cell.cardBackgroundView.backgroundColor = cardArray[row].color
        cell.cardNicknameLabel.text = cardArray[row].nickname
        cell.cardNicknameLabel.font = cell.cardNicknameLabel.font.withSize((UIDevice.current.userInterfaceIdiom == .pad ? 38 : 16))
        
        cell.cardNicknameLabel.textColor = cardArray[row].textColor
        cell.cardDetailsLabel.text = "\(String(describing: cardArray[row].type ?? "")) \(String(describing: cardArray[row].fourDigits ?? ""))"
        
        cell.cardDetailsLabel.font = cell.cardDetailsLabel.font.withSize((UIDevice.current.userInterfaceIdiom == .pad ? 32 : 14))
        
        cell.cardDetailsLabel.textColor = cardArray[row].textColor
        
        return cell
        ///
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cardArray.count + 1
    }
    
}


extension WalletViewController: UISplitViewControllerDelegate {
    
    override func collapseSecondaryViewController(_ secondaryViewController: UIViewController, for splitViewController: UISplitViewController) {
        
        
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, showDetail vc: UIViewController, sender: Any?) -> Bool {
        if let theVC = vc as? ServicesViewController {
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
    func walletViewController(controller: WalletViewController, didSelectCard card: CardClass)
}







