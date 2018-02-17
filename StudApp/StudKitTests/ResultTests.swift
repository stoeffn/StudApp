//
//  ResultTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 31.10.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

@testable import StudKit
import XCTest

final class ResultTests: XCTestCase {

    // MARK: - Initializing

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

    // MARK: - Mapping

    func testMap_Value() {
        let result = Result(42).map { String($0) }
        XCTAssertEqual(result.value, "42")
        XCTAssertTrue(result.isSuccess)
        XCTAssertFalse(result.isFailure)
    }

    func testMap_NoValue() {
        let result = Result<Int>(nil).map { String($0) }
        XCTAssertNil(result.value)
        XCTAssertFalse(result.isSuccess)
        XCTAssertTrue(result.isFailure)
    }

    func testMap_Nil() {
        let result = Result(42).map { _ -> String? in nil }
        XCTAssertNil(result.value!)
        XCTAssertTrue(result.isSuccess)
        XCTAssertFalse(result.isFailure)
    }

    func testMap_Throw() {
        let result = Result(42).map { _ in throw NSError(domain: "abc", code: 0) }
        XCTAssertNil(result.value)
        XCTAssertFalse(result.isSuccess)
        XCTAssertTrue(result.isFailure)
    }

    func testCompactMap_Value() {
        let result = Result(42).compactMap { String($0) }
        XCTAssertEqual(result.value, "42")
        XCTAssertTrue(result.isSuccess)
        XCTAssertFalse(result.isFailure)
    }

    func testCompactMap_NoValue() {
        let result = Result<Int>(nil).compactMap { String($0) }
        XCTAssertNil(result.value)
        XCTAssertFalse(result.isSuccess)
        XCTAssertTrue(result.isFailure)
    }

    func testCompactMap_Nil() {
        let result = Result(42).compactMap { _ -> String? in nil }
        XCTAssertNil(result.value)
        XCTAssertFalse(result.isSuccess)
        XCTAssertTrue(result.isFailure)
    }

    func testCompactMap_Throw() {
        let result = Result(42).compactMap { _ in throw NSError(domain: "abc", code: 0) }
        XCTAssertNil(result.value)
        XCTAssertFalse(result.isSuccess)
        XCTAssertTrue(result.isFailure)
    }
}
