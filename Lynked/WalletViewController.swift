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
    
    
    @IBOutlet weak var leftNavButton: UIBarButtonItem!
    @IBOutlet weak var rightNavButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    var selectedCard: String?
    var cardNicknameToTransfer: String?
    var card4ToTransfer: String?
    var cardtypeToTransfer: String?
    var cardArray: [CardClass] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        title = "Wallet"
        setNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        pullAllUsersCards()
        tableView.isUserInteractionEnabled = true
    }
    
    func pullAllUsersCards() {
        MBProgressHUD.showAdded(to: view, animated: true)
        FirebaseUtility.shared.getCards { (cards, errMessage) in
            MBProgressHUD.hide(for: self.view, animated: true)
            if let theCards = cards {
                if theCards.count < 1 {
                    if let addVC = self.storyboard?.instantiateViewController(withIdentifier: "AddCardVC") as? AddCardViewController {
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
    
    
    // MARK: - IB Actions
    
    @IBAction func leftBarButtonTapped(_ sender: UIBarButtonItem) {
        if let prefVC = self.storyboard?.instantiateViewController(withIdentifier: "PrefVC") as? PreferencesViewController {
            self.navigationController?.pushViewController(prefVC, animated: true)
        }
    }
    
    
    @IBAction func rightBarButtonTapped(_ sender: UIBarButtonItem) {
        
        if InAppPurchaseUtility.shared.isPurchased {
            if let addCardVC = self.storyboard?.instantiateViewController(withIdentifier: "AddCardVC") as? AddCardViewController {
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
            present(actionSheet, animated: true, completion: nil)
        }
    }
    
    func purchaseProduct() {
        InAppPurchaseUtility.shared.purchaseProduct { (success, error) in
            if success {
                if let addCardVC = self.storyboard?.instantiateViewController(withIdentifier: "AddCardVC") as? AddCardViewController {
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
                if let addCardVC = self.storyboard?.instantiateViewController(withIdentifier: "AddCardVC") as? AddCardViewController {
                    self.navigationController?.pushViewController(addCardVC, animated: true)
                }
            }
            else  {
                self.showAlertWith(title: "Purchase Failed!", message: error?.localizedDescription)
            }
        }
    }
}


// MARK: - TableView Delegate & Data Source Methods

extension WalletViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            let row = indexPath.row
            self.selectedCard = self.cardArray[row].cardID
            if self.selectedCard != "" {
                if let cardDVC = self.storyboard?.instantiateViewController(withIdentifier: "CardDetailVC") as? CardDetailViewController {
                    cardDVC.card = self.cardArray[indexPath.row]
                    self.navigationController?.pushViewController(cardDVC, animated: true)
                }
            }
            tableView.isUserInteractionEnabled = false
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! CardTableViewCell
        let row = indexPath.row
        
        cell.cardBackgroundView.backgroundColor = cardArray[row].color
        cell.cardNicknameLabel.text = cardArray[row].nickname
        cell.cardNicknameLabel.textColor = cardArray[row].textColor
        cell.cardDetailsLabel.text = "\(String(describing: cardArray[row].type ?? "")) \(String(describing: cardArray[row].fourDigits ?? ""))"
        cell.cardDetailsLabel.textColor = cardArray[row].textColor
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cardArray.count
    }
    
}
