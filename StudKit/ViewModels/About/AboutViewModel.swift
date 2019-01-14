//
//  StudApp—Stud.IP to Go
//  Copyright © 2018, Steffen Ryll
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see http://www.gnu.org/licenses/.
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
    private var tipProductsRequestCompletion: (([SKProduct]) -> Void)?

    public var leaveTipCompletion: ((SKPaymentTransaction) -> Void)?

    public func tipProducts(completion: @escaping ([SKProduct]) -> Void) {
        tipProductsRequest = SKProductsRequest(productIdentifiers: StoreService.tipProductIdentifiers)
        tipProductsRequest?.delegate = self
        tipProductsRequest?.start()

        tipProductsRequestCompletion = completion
    }

    public func productsRequest(_: SKProductsRequest, didReceive response: SKProductsResponse) {
        tipProductsRequestCompletion?(response.products)

        tipProductsRequest = nil
        tipProductsRequestCompletion = nil
    }

    public func leaveTip(with product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
}

// MARK: - Observing Transactions

extension AboutViewModel: SKPaymentTransactionObserver {
    public func paymentQueue(_: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            guard StoreService.tipProductIdentifiers.contains(transaction.payment.productIdentifier) else { continue }
            leaveTipCompletion?(transaction)
        }
    }
}

// MARK: - Thanking People

public typealias ThanksNote = (title: String, description: String, url: URL?)

extension AboutViewModel: DataSourceSection {
    public typealias Row = ThanksNote

    private static let thanksNotes: [ThanksNote] = [
        (title: "Julian Lobe", description: "Beta-Tester, QA-Man, and Friend", url: nil),
        (title: "Cornelis Kater", description: "Support and Communication", url: nil),
        (title: "Rasmus Fuhse", description: "API Support and Technical Expertise", url: nil),
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
