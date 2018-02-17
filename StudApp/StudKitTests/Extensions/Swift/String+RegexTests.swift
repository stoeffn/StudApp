//
//  String+RegexTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 04.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import XCTest
@testable import StudKit

final class StringRegexTests: XCTestCase {
    // MARK: - Replacing Matches

    func testReplacingMatches_Match() {
        XCTAssertEqual(try! "This is an 'awesome' test!".replacingMatches(for: " is ", with: " was "), "This was an 'awesome' test!")
    }

    func testReplacingMatches_Throw() {
        XCTAssertThrowsError(try "This is another test.".replacingMatches(for: "[", with: "abc"))
    }

    // MARK: - Getting Matches

    func testFirstMatch_Match() {
        XCTAssertEqual(try! "This is another test.".firstMatch(for: " [a-z]+ "), " is ")
    }

    func testFirstMatch_NoMatch() {
        XCTAssertNil(try! "This is another test.".firstMatch(for: "[0-9]"))
    }

    func testFirstMatch_Throw() {
        XCTAssertThrowsError(try "This is another test.".firstMatch(for: "["))
    }
}
