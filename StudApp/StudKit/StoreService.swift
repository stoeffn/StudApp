//
//  StoreService.swift
//  StudKit
//
//  Created by Steffen Ryll on 30.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StoreKit

final class StoreService: NSObject, SKPaymentTransactionObserver {
    init(addAsObserver: Bool = true) {
        super.init()

        SKPaymentQueue.default().add(self)
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print(transactions)
    }
}
