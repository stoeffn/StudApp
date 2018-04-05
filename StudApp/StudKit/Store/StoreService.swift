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
            guard StoreService.tipProductIdentifiers.contains(transaction.payment.productIdentifier) else { continue }
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
