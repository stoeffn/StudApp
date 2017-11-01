//
//  Int+NSNumberTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 30.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import XCTest
@testable import StudKit

final class IntNSNumberTests : XCTestCase {
    func testNsNumber() {
        XCTAssertEqual(42.nsNumber, NSNumber(integerLiteral: 42))
    }
}
