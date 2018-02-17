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

    static let subscriptionProductIdentifier = "SteffenRyll.StudApp.Subscription"

    static let unlockProductIdentifier = "SteffenRyll.StudApp.Unlock"

    static let tipProductIdentifiers: Set = [
        "SteffenRyll.StudApp.Tips.ExtraSmall",
        "SteffenRyll.StudApp.Tips.Small",
        "SteffenRyll.StudApp.Tips.Medium",
        "SteffenRyll.StudApp.Tips.Large",
        "SteffenRyll.StudApp.Tips.ExtraLarge",
    ]

    // MARK: - Constants

    let verificationApi: Api<StoreRoutes>

    // MARK: - Life Cycle

    init(verificationApi: Api<StoreRoutes>) {
        self.verificationApi = verificationApi

        super.init()

        SKPaymentQueue.default().add(self)
    }

    deinit {
        SKPaymentQueue.default().remove(self)
    }

    // MARK: - Providing and Verifying State

    public private(set) lazy var state = State.fromDefaults ?? .locked

    func verifyStateWithServer(completion: @escaping ResultHandler<State>) {
        state = State.fromDefaults ?? state

        guard !state.isVerifiedByServer else { return completion(.success(state)) }

        guard
            let receiptUrl = Bundle.main.appStoreReceiptURL,
            let data = try? Data(contentsOf: receiptUrl)
        else {
            state = State.locked
            state.toDefaults()
            return completion(.success(state))
        }

        verificationApi.requestDecoded(.verify(receipt: data)) { (result: Result<State>) in
            self.state = result.value?.markedAsVerifiedByServer ?? self.state
            self.state.toDefaults()
            completion(result.map { _ in self.state })
        }
    }
}

// MARK: - Processing Transactions

extension StoreService: SKPaymentTransactionObserver {
    public func paymentQueue(_: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.payment.productIdentifier {
            case StoreService.subscriptionProductIdentifier, StoreService.unlockProductIdentifier:
                updateState(with: transaction)
            case _ where StoreService.tipProductIdentifiers.contains(transaction.payment.productIdentifier):
                processTip(with: transaction)
            default:
                break
            }
        }
    }

    func updateState(with transaction: SKPaymentTransaction) {
        switch transaction.transactionState {
        case .purchased:
            state = .unlocked(verifiedByServer: false)
            state.toDefaults()

            verifyStateWithServer { result in
                guard let state = result.value, state.isUnlocked else { return }
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        case .restored:
            SKPaymentQueue.default().finishTransaction(transaction)
        case .deferred:
            state = .deferred
            state.toDefaults()
        default:
            break
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
