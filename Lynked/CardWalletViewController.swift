//
//  WalletViewController.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 5/31/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit
import Firebase
import StoreKit

class CardWalletViewController: UIViewController {
    
    
    @IBOutlet weak var leftNavButton: UIBarButtonItem!
    @IBOutlet weak var rightNavButton: UIBarButtonItem!
    
    @IBOutlet weak var tableView: UITableView!
    
    var selectedCard: String?
    var cardNicknameToTransfer: String?
    var card4ToTransfer: String?
    var cardtypeToTransfer: String?
    let ref = Database.database().reference()
    let user = Auth.auth().currentUser
    var cardArray: [CardClass] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        setNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkFirst()
        tableView.isUserInteractionEnabled = true
    }
    
    // MARK: Nav Bar & View Design
    
    func setNavBar() {
        self.navigationController?.isNavigationBarHidden = false
        title = "Wallet"
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
    
    func checkFirst() {
        self.ref.child("users").child((self.user?.uid)!).child("cards")
            .observe(.value, with: { snapshot in
                if (snapshot.hasChildren()) {
                    self.checkIfDataExits()
                } else {
                    if let addVC = self.storyboard?.instantiateViewController(withIdentifier: "AddCardVC") as? AddCardViewController {
                        self.navigationController?.pushViewController(addVC, animated: true)
                    }
                }
            })
    }
    
    
    // MARK: Firebase Methods
    
    func checkIfDataExits() {
        DispatchQueue.main.async {
            self.cardArray.removeAll()
            self.ref.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                if snapshot.hasChild("cards") {
                    self.pullAllUsersCards()
                } else {
                    if let addVC = self.storyboard?.instantiateViewController(withIdentifier: "AddCardVC") as? AddCardViewController {
                        self.navigationController?.pushViewController(addVC, animated: true)
                    }
                }
            })
        }
    }
    
    
    func pullAllUsersCards() {
        cardArray.removeAll()
        let userRef = ref.child("users").child((user?.uid)!).child("cards")
        userRef.observe(DataEventType.value, with: { (snapshot) in
            for userscard in snapshot.children {
                let cardID = (userscard as AnyObject).key as String
                let cardRef = self.ref.child("cards").child(cardID)
                cardRef.observe(DataEventType.value, with: { (cardSnapShot) in
                    let cardSnap = cardSnapShot as DataSnapshot

                    if let cardDict = cardSnap.value as? [String: AnyObject] {
                        let cardNickname = cardDict["nickname"]
                        let card4D = cardDict["last4"]
                        let cardType = cardDict["type"]
                        self.cardNicknameToTransfer = (cardNickname as? String)!
                        self.card4ToTransfer = (card4D as? String)!
                        self.cardtypeToTransfer = (cardType as? String)!
                        let aCard = CardClass(cardDict: cardDict)
                        aCard.cardID = cardID
                        self.cardArray.append(aCard)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                })
            }
        })
    }
    
    
    // MARK: IB Actions
    
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
            
        }
        else {
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


// MARK: TableView Delegate & Data Source Methods

extension CardWalletViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125.0
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            let row = indexPath.row
            self.selectedCard = self.cardArray[row].cardID
            if self.selectedCard != "" {
                if let cardDVC = self.storyboard?.instantiateViewController(withIdentifier: "CardDetailVC") as? CardDetailViewController {
                    cardDVC.cardID = self.selectedCard ?? ""
                    self.navigationController?.pushViewController(cardDVC, animated: true)
                }
            }
            tableView.isUserInteractionEnabled = false
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! CardTableViewCell
        let row = indexPath.row
        cell.cardNicknameLabel.text = cardArray[row].nickname
        cell.cardDetailsLabel.text = "\(String(describing: cardArray[row].type ?? "")) \(String(describing: cardArray[row].fourDigits ?? ""))"
//        cell.cardDe.text = cardArray[row].type
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cardArray.count
    }
    
    
}










