//
//  ApiRoutesTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 28.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

@testable import StudKit
import XCTest

final class ApiRoutesTests: XCTestCase {
    private struct Routes: ApiRoutes {
        let path: String = ""
    }

    // MARK: - Types

    func testType_Nil() {
        XCTAssertNil(Routes().type)
    }
}
