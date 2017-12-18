//
//  StoreService.swift
//  StudKit
//
//  Created by Steffen Ryll on 30.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StoreKit

public final class StoreService: NSObject {
    // MARK: - Constants

    let subscriptionProductIdentifier = "SteffenRyll.StudApp.Subscription"

    let unlockProductIdentifier = "SteffenRyll.StudApp.Unlock"

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

    // MARK: - Managing State

    public private(set) lazy var state = State.fromDefaults ?? .locked

    func verifyStateWithServer(handler: @escaping ResultHandler<State>) {
        state = State.fromDefaults ?? state

        guard !state.isVerifiedByServer else { return handler(.success(state)) }

        guard
            let receiptUrl = Bundle.main.appStoreReceiptURL,
            let data = try? Data(contentsOf: receiptUrl)
        else {
            state = State.locked
            state.toDefaults()
            return handler(.success(state))
        }

        verificationApi.requestDecoded(.verify(receipt: data)) { (result: Result<State>) in
            self.state = result.value?.markedAsVerifiedByServer ?? self.state
            self.state.toDefaults()
            handler(result.replacingValue(self.state))
        }
    }
}

// MARK: - Payment Transaction Observer

extension StoreService: SKPaymentTransactionObserver {
    public func paymentQueue(_: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            updateState(using: transaction)
        }
    }

    func updateState(using transaction: SKPaymentTransaction) {
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
}
