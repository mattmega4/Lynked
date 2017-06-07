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

class WalletViewController: UIViewController {  // SKProductsRequestDelegate, SKPaymentTransactionObserver
    
    
    @IBOutlet weak var leftNavButton: UIBarButtonItem!
    @IBOutlet weak var rightNavButton: UIBarButtonItem!
    
    @IBOutlet weak var tableView: UITableView!
    
    var selectedCard: String?
    var cardNicknameToTransfer = ""
    var cardtypeToTransfer = ""
    let ref = Database.database().reference()
    let user = Auth.auth().currentUser
    var cardArray: [CardClass] = []
    
//    let CARD_PRODUCT_ID = "com.Lynked.card"
//    
//    var productID = ""
//    var productsRequest = SKProductsRequest()
//    var iapProducts = [SKProduct]()
//    var nonConsumablePurchaseMade = UserDefaults.standard.bool(forKey: "nonConsumablePurchaseMade")
//    var coins = UserDefaults.standard.integer(forKey: "coins")
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        setNavBar()
        
        
//        if nonConsumablePurchaseMade {
//            print("Premium version PURCHASED!")
//        } else {
//            print("Premium version LOCKED!")
//        }
//        
//        // Fetch IAP Products available
//        fetchAvailableProducts()
        
        
        
        
        
        
        
        
    }
    
    
    
    
//    
//    //// IN APP METHOD
//    
//    
//    
//    
//    // MARK: - FETCH AVAILABLE IAP PRODUCTS
//    func fetchAvailableProducts()  {
//        
//        // Put here your IAP Products ID's
//        let productIdentifiers = NSSet(objects:
//            CARD_PRODUCT_ID
//        )
//        
//        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
//        productsRequest.delegate = self
//        productsRequest.start()
//    }
//    
//    
//    
//    // MARK: - REQUEST IAP PRODUCTS
//    func productsRequest (_ request:SKProductsRequest, didReceive response:SKProductsResponse) {
//        if (response.products.count > 0) {
//            iapProducts = response.products
//            
//            // 1st IAP Product (Consumable) ------------------------------------
//            let firstProduct = response.products[0] as SKProduct
//            
//            // Get its price from iTunes Connect
//            let numberFormatter = NumberFormatter()
//            numberFormatter.formatterBehavior = .behavior10_4
//            numberFormatter.numberStyle = .currency
//            numberFormatter.locale = firstProduct.priceLocale
//            let price1Str = numberFormatter.string(from: firstProduct.price)
//            
//            // Show its description
//            consumableLabel.text = firstProduct.localizedDescription + "\nfor just \(price1Str!)"
//            // ------------------------------------------------
//            
//            
//            
//            // 2nd IAP Product (Non-Consumable) ------------------------------
//            let secondProd = response.products[1] as SKProduct
//            
//            // Get its price from iTunes Connect
//            numberFormatter.locale = secondProd.priceLocale
//            let price2Str = numberFormatter.string(from: secondProd.price)
//            
//            // Show its description
//            nonConsumableLabel.text = secondProd.localizedDescription + "\nfor just \(price2Str!)"
//            // ------------------------------------
//        }
//    }
//    
//    
//    // MARK: - MAKE PURCHASE OF A PRODUCT
//    func canMakePurchases() -> Bool {  return SKPaymentQueue.canMakePayments()  }
//    func purchaseMyProduct(product: SKProduct) {
//        if self.canMakePurchases() {
//            let payment = SKPayment(product: product)
//            SKPaymentQueue.default().add(self)
//            SKPaymentQueue.default().add(payment)
//            
//            print("PRODUCT TO PURCHASE: \(product.productIdentifier)")
//            productID = product.productIdentifier
//            
//            
//            // IAP Purchases dsabled on the Device
//        } else {
//            UIAlertView(title: "IAP Tutorial",
//                        message: "Purchases are disabled in your device!",
//                        delegate: nil, cancelButtonTitle: "OK").show()
//        }
//    }
//    
//    
//    // MARK:- IAP PAYMENT QUEUE
//    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
//        for transaction:AnyObject in transactions {
//            if let trans = transaction as? SKPaymentTransaction {
//                switch trans.transactionState {
//                    
//                case .purchased:
//                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
//                    
//                    // The Consumable product (10 coins) has been purchased -> gain 10 extra coins!
//                    if productID == COINS_PRODUCT_ID {
//                        
//                        // Add 10 coins and save their total amount
//                        coins += 10
//                        UserDefaults.standard.set(coins, forKey: "coins")
//                        coinsLabel.text = "COINS: \(coins)"
//                        
//                        UIAlertView(title: "IAP Tutorial",
//                                    message: "You've successfully bought 10 extra coins!",
//                                    delegate: nil,
//                                    cancelButtonTitle: "OK").show()
//                        
//                        
//                        
//                        // The Non-Consumable product (Premium) has been purchased!
//                    } else if productID == PREMIUM_PRODUCT_ID {
//                        
//                        // Save your purchase locally (needed only for Non-Consumable IAP)
//                        nonConsumablePurchaseMade = true
//                        UserDefaults.standard.set(nonConsumablePurchaseMade, forKey: "nonConsumablePurchaseMade")
//                        
//                        premiumLabel.text = "Premium version PURCHASED!"
//                        
//                        UIAlertView(title: "IAP Tutorial",
//                                    message: "You've successfully unlocked the Premium version!",
//                                    delegate: nil,
//                                    cancelButtonTitle: "OK").show()
//                    }
//                    
//                    break
//                    
//                case .failed:
//                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
//                    break
//                case .restored:
//                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
//                    break
//                    
//                default: break
//                }}}
//    }
//    
//    
//    
//    ////
//    
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkIfDataExits()
        tableView.isUserInteractionEnabled = true
        
    }
    
    
    
    // MARK: Nav Bar & View Design
    
    func setNavBar() {
        title = "Wallet"
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
            self.cardArray.removeAll()
            self.ref.observe(DataEventType.value, with: { (snapshot) in
                if snapshot.hasChild("cards") {
                    self.pullAllUsersCards()
                } else {
                    self.tableView.reloadData()
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
                    let cardDict = cardSnap.value as! [String: AnyObject]
                    let cardNickname = cardDict["nickname"]
                    let cardType = cardDict["type"]
                    let cardStatus = cardDict["cardStatus"]
                    self.cardNicknameToTransfer = cardNickname as! String
                    self.cardtypeToTransfer = cardType as! String
                    let aCard = CardClass()
                    aCard.cardID = cardID
                    aCard.nickname = cardNickname as! String
                    aCard.type = cardType as! String
                    aCard.cStatus = cardStatus as! Bool
                    self.cardArray.append(aCard)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                })
            }
        })
    }
    
    
    
    
    
    // MARK: Prepare for Segue Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromWalletToCardDetails" {
            if let controller = segue.destination as? UINavigationController {
                if let destinationVC = controller.topViewController as? CardDetailViewController {
                    destinationVC.cardID = selectedCard!
                }
            }
        }
    }
    
    
    // MARK: IB Actions
    
    @IBAction func leftBarButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "fromWalletToPref", sender: self)
    }
    
    @IBAction func rightBarButtonTapped(_ sender: UIBarButtonItem) {
        if InAppPurchaseUtility.shared.isPurchased {
            performSegue(withIdentifier: "fromWalletToAddCard", sender: self)
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
        InAppPurchaseUtility.shared.purchaseProduct { (transaction) in
            if let theTransaction = transaction {
                switch theTransaction.transactionState {
                case .failed:
                    self.showAlertWith(title: "Purchase Failed!", message: theTransaction.error?.localizedDescription)
                case .purchased:
                    self.showAlertWith(title: "Success!", message: "Your purchase was successful")
                default:
                    print("Other things")
                }
            }
            else {
                self.showAlertWith(title: "Error", message: "There was an error completing the purchase. Please try later")
            }
        }
    }
    
    func restorePurchase() {
        InAppPurchaseUtility.shared.restorePurchase { (transaction) in
            if let theTransaction = transaction {
                switch theTransaction.transactionState {
                case .failed:
                    self.showAlertWith(title: "Restore Failed!", message: theTransaction.error?.localizedDescription)
                case .restored:
                    self.showAlertWith(title: "Success!", message: "This item was successfully restored")
                default:
                    print("Other things")
                }
            }
            else {
                self.showAlertWith(title: "Error", message: "There was an error completing the purchase. Please try later")
            }
        }
    }
    
    
}


// MARK: TableView Delegate & Data Source Methods

extension WalletViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125.0
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            let row = indexPath.row
            self.selectedCard = self.cardArray[row].cardID as String
            if self.selectedCard != "" {
                self.performSegue(withIdentifier: "fromWalletToCardDetails", sender: self)
            }
            tableView.isUserInteractionEnabled = false
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! CardTableViewCell
        let row = indexPath.row
        cell.cardNicknameLabel.text = cardArray[row].nickname
        cell.cardTypeLabel.text = cardArray[row].type
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cardArray.count
    }
    
    
}

//extension WalletViewController: SKProductsRequestDelegate, SKPaymentTransactionObserver {
//
//}








