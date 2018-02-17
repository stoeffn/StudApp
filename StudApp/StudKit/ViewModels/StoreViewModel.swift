//
//  StoreViewModel.swift
//  StudKit
//
//  Created by Steffen Ryll on 30.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StoreKit

public final class StoreViewModel: NSObject {

    // MARK: - State

    public enum State {
        case idle
        case loadingProducts
        case purchasing
        case purchased
        case deferred
        case restored
        case failure(Error)
    }

    /// Current state of the store, which should be respected by the user interface.
    public var state: State = .idle {
        didSet { stateChanged?(state) }
    }

    /// This handler is called every time `state` changes.
    public var stateChanged: ((State) -> Void)?

    // MARK: - Life Cycle

    private let storeService = ServiceContainer.default[StoreService.self]
    private let studIpService = ServiceContainer.default[StudIpService.self]
    private var productsRequest: SKProductsRequest?

    public override init() {
        super.init()

        state = storeService.state.isDeferred ? .deferred : .idle
    }

    // MARK: - Products

    public private(set) var subscriptionProduct: SKProduct?

    public private(set) var unlockProduct: SKProduct?

    public func loadProducts() {
        state = .loadingProducts

        productsRequest = SKProductsRequest(productIdentifiers: [
            StoreService.subscriptionProductIdentifier,
            StoreService.unlockProductIdentifier,
        ])
        productsRequest?.delegate = self
        productsRequest?.start()
    }

    // MARK: - Actions

    public func addAsTransactionObserver() {
        SKPaymentQueue.default().add(self)
    }

    public func removeAsTransactionObserver() {
        SKPaymentQueue.default().remove(self)
    }

    public func restoreCompletedTransactions() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

    public func buy(product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }

    /// Sign user out of this app and the API.
    public func signOut() {
        studIpService.signOut()
    }
}

// MARK: - Product Request Delegate

extension StoreViewModel: SKProductsRequestDelegate {
    public func productsRequest(_: SKProductsRequest, didReceive response: SKProductsResponse) {
        subscriptionProduct = response.products.first { $0.productIdentifier == StoreService.subscriptionProductIdentifier }
        unlockProduct = response.products.first { $0.productIdentifier == StoreService.unlockProductIdentifier }

        state = storeService.state.isDeferred ? .deferred : .idle
        productsRequest = nil
    }
}

// MARK: - Payment Transaction Observer

extension StoreViewModel: SKPaymentTransactionObserver {
    public func paymentQueue(_: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                state = .purchasing
            case .purchased:
                state = .purchased
            case .failed:
                guard let error = transaction.error else { break }
                state = .failure(error)
            case .restored:
                break
            case .deferred:
                state = .deferred
            }
        }
    }

    public func paymentQueueRestoreCompletedTransactionsFinished(_: SKPaymentQueue) {
        state = .restored
    }

    public func paymentQueue(_: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        state = .failure(error)
    }
}
