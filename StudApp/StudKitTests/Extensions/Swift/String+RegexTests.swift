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
