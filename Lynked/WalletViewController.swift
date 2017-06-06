//
//  WalletViewController.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 5/31/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit
import Firebase

class WalletViewController: UIViewController {
    
    
    @IBOutlet weak var leftNavButton: UIBarButtonItem!
    @IBOutlet weak var rightNavButton: UIBarButtonItem!
    
    @IBOutlet weak var tableView: UITableView!
    
    var selectedCard: String?
    var cardNicknameToTransfer = ""
    var cardtypeToTransfer = ""
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
        performSegue(withIdentifier: "fromWalletToAddCard", sender: self)
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








