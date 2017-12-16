//
//  StoreService.swift
//  StudKit
//
//  Created by Steffen Ryll on 30.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StoreKit

final class StoreService: NSObject {
    // MARK: - Constants

    let subscriptionProductIdentifier = "SteffenRyll.StudApp.Subscription"

    let unlockProductIdentifier = "SteffenRyll.StudApp.Unlock"

    let initialSubscriptionTimeout: TimeInterval = 60 * 60 * 24 * 7

    // MARK: - Life Cycle

    init(addAsObserver _: Bool = true) {
        super.init()

        SKPaymentQueue.default().add(self)

        refreshStateFromServer()
    }

    deinit {
        SKPaymentQueue.default().remove(self)
    }

    // MARK: - Managing State

    private(set) lazy var state = State.fromDefaults ?? .locked

    func refreshStateFromServer(handler: ResultHandler<State>? = nil) {
        handler?(.success(state))
    }
}

// MARK: - Payment Transaction Observer

extension StoreService: SKPaymentTransactionObserver {
    func paymentQueue(_: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            updateState(using: transaction)
        }
    }

    private func updateState(using transaction: SKPaymentTransaction) {
        switch transaction.transactionState {
        case .purchased, .restored:
            didActivateProdct(withIdentifier: transaction.payment.productIdentifier)
        case .deferred:
            state = .deferred
            state.toDefaults()
        default:
            break
        }
    }

    private func didActivateProdct(withIdentifier identifier: String) {
        switch identifier {
        case subscriptionProductIdentifier:
            state = .subscribed(until: Date() + initialSubscriptionTimeout, validatedByServer: false)
        case unlockProductIdentifier:
            state = .unlocked(validatedByServer: false)
        default:
            break
        }

        state.toDefaults()

        refreshStateFromServer()
    }
}
