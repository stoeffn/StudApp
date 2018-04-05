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
