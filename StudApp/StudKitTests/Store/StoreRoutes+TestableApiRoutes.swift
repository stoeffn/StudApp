//
//  StudAppRoutes+TestableApiRoutes.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 16.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

@testable import StudKit

extension StoreRoutes: TestableApiRoutes {
    func testData(for parameters: [URLQueryItem]) throws -> Data {
        switch self {
        case .verifyReceipt:
            let encoder = ServiceContainer.default[JSONEncoder.self]
            return try encoder.encode(StoreService.State.subscribed(until: Date() + 10, verifiedByServer: false))
        }
    }
}
