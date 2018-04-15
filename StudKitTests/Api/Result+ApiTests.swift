//
//  StudApp—Stud.IP to Go
//  Copyright © 2018, Steffen Ryll
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see http://www.gnu.org/licenses/.
//

@testable import StudKit
import XCTest

final class ResultApiTests: XCTestCase {
    private struct Test: Decodable {
        let id: Int
    }

    // MARK: - Initializing

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

    // MARK: - Mapping

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

    // MARK: - Coding

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
