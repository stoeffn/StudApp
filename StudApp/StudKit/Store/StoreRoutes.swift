//
//  StoreRoutes.swift
//  StudKit
//
//  Created by Steffen Ryll on 16.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

enum StoreRoutes: ApiRoutes {
    case verifyReceipt

    var path: String {
        switch self {
        case .verifyReceipt: return "verify-receipt"
        }
    }

    var body: Data? {
        switch self {
        case .verifyReceipt:
            guard
                let receiptUrl = Bundle.main.appStoreReceiptURL,
                let receiptData = try? Data(contentsOf: receiptUrl)
            else { return nil }
            return receiptData
        }
    }

    var type: Decodable.Type? {
        switch self {
        case .verifyReceipt: return StoreService.State.self
        }
    }
}
