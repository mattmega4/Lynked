//
//  InAppPurchaseUtility.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 6/6/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit
import StoreKit

class InAppPurchaseUtility: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    static let shared = InAppPurchaseUtility()
    private var product: SKProduct?
    private var productRequest: SKProductsRequest!
    private var purchaseCompletion: ((_ transaction: SKPaymentTransaction?) -> Void)?
    var isPurchased = false
    
    override init() {
        super.init()
        let identifiers = Set(["com.Lynked.card"])
        productRequest = SKProductsRequest(productIdentifiers: identifiers)
        productRequest.delegate = self
        productRequest.start()
        isPurchased = UserDefaults.standard.bool(forKey: "com.Lynked.card")
    }
    
    // MARK: - SKProductRequest Delegate
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        product = response.products.first
    }
    
    // MARK: Transaction oserver
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        if let transaction = transactions.first {
            purchaseCompletion?(transaction)
            if transaction.transactionState == .purchased {
                UserDefaults.standard.set(true, forKey: "com.Lynked.card")
                self.isPurchased = true
            }
        }
        else {
            purchaseCompletion?(nil)
        }
    }
    

    func purchaseProduct(completion: ((_ transaction: SKPaymentTransaction?) -> Void)?) {
        guard let theProduct = product else {
            completion?(nil)
            return
        }
        let payment = SKPayment(product: theProduct)
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(payment)
    }
    
    func restorePurchase(completion: ((_ transaction: SKPaymentTransaction?) -> Void)?) {
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    

    
    

    
    

}
