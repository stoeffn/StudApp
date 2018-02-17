//
//  Result+ApiTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 24.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import XCTest
@testable import StudKit

final class ResultApiTests: XCTestCase {
    private struct Test: Decodable {
        let id: Int
    }

    func testInit_200_Success() {
        let result = Result(42, statusCode: 200)
        XCTAssertEqual(result.value, 42)
        XCTAssertTrue(result.isSuccess)
        XCTAssertFalse(result.isFailure)
    }

    func testInit_404_Failure() {
        let result = Result(42, statusCode: 404)
        XCTAssertNil(result.value)
        XCTAssertFalse(result.isSuccess)
        XCTAssertTrue(result.isFailure)
    }

    func testInit_Error_Failure() {
        let result = Result(42, error: NSError(domain: "abc", code: 0), statusCode: 200)
        XCTAssertNil(result.value)
        XCTAssertFalse(result.isSuccess)
        XCTAssertTrue(result.isFailure)
        XCTAssertEqual(result.error.debugDescription, "Optional(Error Domain=abc Code=0 \"(null)\")")
    }

    func testInit_NoValue_Failure() {
        let result = Result<Int>(nil, statusCode: 200)
        XCTAssertNil(result.value)
        XCTAssertFalse(result.isSuccess)
        XCTAssertTrue(result.isFailure)
    }

    func testMap_Value_Success() {
        let result = Result(42, statusCode: 200).map { _ in "Hello, World!" }
        XCTAssertEqual(result.value, "Hello, World!")
        XCTAssertTrue(result.isSuccess)
        XCTAssertFalse(result.isFailure)
    }

    func testCompactMap_Nil_Failure() {
        let result: Result<String> = Result(42, statusCode: 200).compactMap { _ in nil }
        XCTAssertNil(result.value)
        XCTAssertFalse(result.isSuccess)
        XCTAssertTrue(result.isFailure)
    }

    func testDecoded_Data_Sucess() {
        let result = Result("{\"id\": 42}".data(using: .utf8), statusCode: 200).decoded(Test.self)
        XCTAssertEqual(result.value?.id, 42)
        XCTAssertTrue(result.isSuccess)
        XCTAssertFalse(result.isFailure)
    }

    func testDecoded_Data_Failure() {
        let result = Result("Hello, World!".data(using: .utf8), statusCode: 200).decoded(Test.self)
        XCTAssertNil(result.value)
        XCTAssertFalse(result.isSuccess)
        XCTAssertTrue(result.isFailure)
    }
}
