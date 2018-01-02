//
//  ResultTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 31.10.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import XCTest
@testable import StudKit

final class ResultTests: XCTestCase {
    func testInit_Value_Success() {
        let result = Result(42)
        XCTAssertEqual(result.value, 42)
        XCTAssertTrue(result.isSuccess)
        XCTAssertFalse(result.isFailure)
    }

    func testInit_Error_Failure() {
        let result = Result(42, error: NSError(domain: "abc", code: 0))
        XCTAssertNil(result.value)
        XCTAssertFalse(result.isSuccess)
        XCTAssertTrue(result.isFailure)
    }

    func testInit_NoValue_Failure() {
        let result = Result<Int>(nil)
        XCTAssertNil(result.value)
        XCTAssertFalse(result.isSuccess)
        XCTAssertTrue(result.isFailure)
    }

    func testReplacingValue_Value_Success() {
        let result = Result(42).replacingValue("Hello, World!")
        XCTAssertEqual(result.value, "Hello, World!")
        XCTAssertTrue(result.isSuccess)
        XCTAssertFalse(result.isFailure)
    }

    func testReplacingValue_Nil_Failure() {
        let result: Result<String> = Result(42).replacingValue(nil)
        XCTAssertNil(result.value)
        XCTAssertFalse(result.isSuccess)
        XCTAssertTrue(result.isFailure)
    }
}
