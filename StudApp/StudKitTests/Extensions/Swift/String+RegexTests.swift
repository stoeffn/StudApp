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
    func testReplaceMatches() {
        XCTAssertEqual("This is an 'awesome' test!".replacingMatches(" is ", with: " was "), "This was an 'awesome' test!")
    }
}
