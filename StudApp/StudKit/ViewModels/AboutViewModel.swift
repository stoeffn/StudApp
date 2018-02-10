//
//  AboutViewModel.swift
//  StudKit
//
//  Created by Steffen Ryll on 28.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StoreKit

public final class AboutViewModel: NSObject, SKProductsRequestDelegate {
    // MARK: - Leaving Tips

    private var productsRequest: SKProductsRequest?
    private var productsRequestCompletionHandler: (([SKProduct]) -> Void)?

    public func tipProducts(completion: @escaping ([SKProduct]) -> Void) {
        productsRequest = SKProductsRequest(productIdentifiers: StoreService.tipProductIdentifiers)
        productsRequest?.delegate = self
        productsRequest?.start()

        productsRequestCompletionHandler = completion
    }

    public func productsRequest(_: SKProductsRequest, didReceive response: SKProductsResponse) {
        productsRequestCompletionHandler?(response.products)

        productsRequest = nil
        productsRequestCompletionHandler = nil
    }

    public func buy(product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
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
