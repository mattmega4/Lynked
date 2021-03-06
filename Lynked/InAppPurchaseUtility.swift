//
//  InAppPurchaseUtility.swift
//  Lynked
//
//  Created by Matthew Howes Singleton on 6/6/17.
//  Copyright © 2017 Matthew Singleton. All rights reserved.
//

import UIKit
import StoreKit
import Firebase
import Fabric
import Crashlytics

class InAppPurchaseUtility: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
  
  static let shared = InAppPurchaseUtility()
  private var product: SKProduct?
  private var productRequest: SKProductsRequest!
  private var purchaseCompletion: ((_ success: Bool, _ error: Error?) -> Void)?
  var isPurchased = false
  
  override init() {
    super.init()
    let identifiers = Set([PurchaseKeys.comLynkedCard])
    productRequest = SKProductsRequest(productIdentifiers: identifiers)
    productRequest.delegate = self
    productRequest.start()
    isPurchased = UserDefaults.standard.bool(forKey: PurchaseKeys.comLynkedCard)
  }
  
  // MARK: - SKProductRequest Delegate
  func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
    product = response.products.first
  }
  
  // MARK: - Transaction oserver
  func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    if let transaction = transactions.first {
      
      if transaction.transactionState == .purchased {
        UserDefaults.standard.set(true, forKey: PurchaseKeys.comLynkedCard)
        self.isPurchased = true
        purchaseCompletion?(true, nil)
        
        // MARK: - Track the user action that is important for you.
        
        Analytics.logEvent(AnalyticsKeys.addCardPurchase, parameters: [AnalyticsKeys.success : true])
        
        Answers.logPurchase(withPrice: PurchaseKeys.price,
                            currency: PurchaseKeys.currency,
                            success: true,
                            itemName: PurchaseKeys.itemName,
                            itemType: PurchaseKeys.itemType,
                            itemId: PurchaseKeys.itemId,
                            customAttributes: nil)
        
        
      } else if transaction.transactionState == .failed {
        purchaseCompletion?(false, transaction.error)
      } else if transaction.transactionState == .restored {
        purchaseCompletion?(true, nil)
      }
    } else {
      purchaseCompletion?(false, nil)
    }
  }
  
  func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
    purchaseCompletion?(true, nil)
  }
  
  func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
    purchaseCompletion?(false, error)
  }
  
  
  func purchaseProduct(completion: ((_ success: Bool, _ error: Error?) -> Void)?) {
    purchaseCompletion = completion
    guard let theProduct = product else {
      completion?(false, nil)
      return
    }
    let payment = SKPayment(product: theProduct)
    SKPaymentQueue.default().add(self)
    SKPaymentQueue.default().add(payment)
  }
  
  func restorePurchase(completion: ((_ success: Bool, _ error: Error?) -> Void)?) {
    purchaseCompletion = completion
    SKPaymentQueue.default().add(self)
    SKPaymentQueue.default().restoreCompletedTransactions()
  }
  
}
