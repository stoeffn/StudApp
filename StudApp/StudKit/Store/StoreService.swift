//
//  StoreService.swift
//  StudKit
//
//  Created by Steffen Ryll on 30.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StoreKit

public final class StoreService: NSObject {

    // MARK: - Products

    static let tipProductIdentifiers: Set = [
        "SteffenRyll.StudApp.Tips.ExtraSmall",
        "SteffenRyll.StudApp.Tips.Small",
        "SteffenRyll.StudApp.Tips.Medium",
        "SteffenRyll.StudApp.Tips.Large",
        "SteffenRyll.StudApp.Tips.ExtraLarge",
    ]

    // MARK: - Life Cycle

    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }

    deinit {
        SKPaymentQueue.default().remove(self)
    }
}

// MARK: - Processing Transactions

extension StoreService: SKPaymentTransactionObserver {
    public func paymentQueue(_: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            guard StoreService.tipProductIdentifiers.contains(transaction.payment.productIdentifier) else { fatalError() }
            processTip(with: transaction)
        }
    }

    func processTip(with transaction: SKPaymentTransaction) {
        switch transaction.transactionState {
        case .purchased, .restored:
            SKPaymentQueue.default().finishTransaction(transaction)
        default:
            break
        }
    }
}
