//
//  Array+SetTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 30.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import XCTest
@testable import StudKit

final class ArraySetTests: XCTestCase {
    func testSet() {
        XCTAssertEqual([1, 2, 3].set, Set(arrayLiteral: 1, 2, 3))
    }
}
