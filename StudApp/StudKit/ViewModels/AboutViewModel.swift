//
//  AboutViewModel.swift
//  StudKit
//
//  Created by Steffen Ryll on 28.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StoreKit

public final class AboutViewModel: NSObject, SKProductsRequestDelegate {
    // MARK: - Life Cycle

    public override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }

    deinit {
        SKPaymentQueue.default().remove(self)
    }

    // MARK: - Leaving Tips

    private var tipProductsRequest: SKProductsRequest?
    private var tipProductsRequestCompletionHandler: (([SKProduct]) -> Void)?

    public var leaveTipCompletionHandler: ((SKPaymentTransaction) -> Void)?

    public func tipProducts(completion: @escaping ([SKProduct]) -> Void) {
        tipProductsRequest = SKProductsRequest(productIdentifiers: StoreService.tipProductIdentifiers)
        tipProductsRequest?.delegate = self
        tipProductsRequest?.start()

        tipProductsRequestCompletionHandler = completion
    }

    public func productsRequest(_: SKProductsRequest, didReceive response: SKProductsResponse) {
        tipProductsRequestCompletionHandler?(response.products)

        tipProductsRequest = nil
        tipProductsRequestCompletionHandler = nil
    }

    public func leaveTip(with product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
}

// MARK: - Observing Transactions

extension AboutViewModel: SKPaymentTransactionObserver {
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            guard StoreService.tipProductIdentifiers.contains(transaction.payment.productIdentifier) else { continue }
            leaveTipCompletionHandler?(transaction)
        }
    }
}

// MARK: - Thanking People

public typealias ThanksNote = (title: String, description: String, url: URL?)

extension AboutViewModel: DataSourceSection {
    public typealias Row = ThanksNote

    private static let thanksNotes: [ThanksNote] = [
        (title: "Julian Lobe", description: "Beta-Tester, QA-Man, and Friend", url: nil),
        (title: "Cornelis Kater", description: "Support and Communication", url: URL(string: "http://ckater.de/")),
        (title: "Stud.IP e.V.", description: "Development of APIs", url: URL(string: "http://studip.de/")),
        (title: "icons8", description: "Glyphs", url: URL(string: "https://icons8.com/")),
    ]

    public var numberOfRows: Int {
        return AboutViewModel.thanksNotes.count
    }

    public subscript(rowAt index: Int) -> ThanksNote {
        return AboutViewModel.thanksNotes[index]
    }
}
