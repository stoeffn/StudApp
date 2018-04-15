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

final class ApiTests: XCTestCase {
    private let api = MockApi<TestRoutes>(baseUrl: URL(string: "https://example.com")!)

    // MARK: - Requesting

    func testRequestDecoded_Request_Value() {
        api.requestDecoded(.object) { (result: Result<Test>) in
            XCTAssertTrue(result.isSuccess)
            XCTAssertEqual(result.value?.id, "42")
        }
    }
}
