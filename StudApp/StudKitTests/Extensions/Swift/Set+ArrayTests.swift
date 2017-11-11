//
//  Set+ArrayTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 30.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import XCTest
@testable import StudKit

final class SetArrayTests: XCTestCase {
    func testArray() {
        XCTAssertEqual(([1, 2, 3] as Set).array.sorted(), [1, 2, 3])
    }
}
