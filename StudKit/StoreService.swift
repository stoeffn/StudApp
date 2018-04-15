//
//  StoreService.swift
//  StudKit
//
//  Created by Steffen Ryll on 30.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StoreKit

final class StoreService: NSObject, SKPaymentTransactionObserver {
    private let subscriptionProductIdentifier = "SteffenRyll.StudApp.Subscriptions.Students.SixMonths"

    init(addAsObserver _: Bool = true) {
        super.init()

        SKPaymentQueue.default().add(self)
    }

    func paymentQueue(_: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased, .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                break
            }
        }
    }
}
