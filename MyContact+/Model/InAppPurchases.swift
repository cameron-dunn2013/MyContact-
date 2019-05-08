//
//  InAppPurchases.swift
//  MyContact+
//
//  Created by Cameron Dunn on 5/7/19.
//  Copyright © 2019 Cameron Dunn. All rights reserved.
//

import Foundation
import StoreKit

class StoreObserver: NSObject, SKPaymentTransactionObserver {
    //Initialize the store observer.
    override init() {
        super.init()
        //Other initialization here.
    }
    
    //Observe transaction updates.
    func paymentQueue(_ queue: SKPaymentQueue,updatedTransactions transactions: [SKPaymentTransaction]) {
        //Handle transaction states here.
    }
}
