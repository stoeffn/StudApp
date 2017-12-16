//
//  StoreServiceTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 16.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StoreKit
import XCTest
@testable import StudKit

final class StoreServiceTests: XCTestCase {
    private let storeService = ServiceContainer.default[StoreService.self]

    func testVerfifyStateWithServer() {
        storeService.verifyStateWithServer { result in
            XCTAssertTrue(result.isSuccess)
            XCTAssertTrue(result.value?.isUnlocked ?? false)
            XCTAssertTrue(result.value?.isVerifiedByServer ?? false)
        }
        XCTAssertTrue(StoreService.State.fromDefaults?.isUnlocked ?? false)
    }
}
