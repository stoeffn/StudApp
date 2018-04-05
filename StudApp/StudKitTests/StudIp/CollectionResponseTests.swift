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

final class CollectionResponseTests: XCTestCase {
    private let decoder = ServiceContainer.default[JSONDecoder.self]
    private let data = """
        {
            "collection": {
                "abc": "123",
                "def": "456"
            },
            "pagination": {
                "total": 42,
                "offset": 0,
                "limit": 32
            }
        }
    """.data(using: .utf8)!

    // MARK: - Coding

    func testDecodeCollection() {
        let collection = try! decoder.decode(CollectionResponse<String>.self, from: data)

        XCTAssertNotNil(collection)
        XCTAssertEqual(collection.items, ["123", "456"])
    }

    func testDecodePagination() {
        let collection = try! decoder.decode(CollectionResponse<String>.self, from: data)

        XCTAssertNotNil(collection)
        XCTAssertEqual(collection.pagination.total, 42)
        XCTAssertEqual(collection.pagination.offset, 0)
        XCTAssertEqual(collection.pagination.limit, 32)
    }

    // MARK: - Calculating the Next Offset

    func testNextOffset_0_5() {
        let pagination = CollectionResponse<String>.Pagination(total: 11, offset: 0, limit: 5)
        XCTAssertEqual(pagination.nextOffset, 5)
    }

    func testNextOffset_5_10() {
        let pagination = CollectionResponse<String>.Pagination(total: 11, offset: 5, limit: 5)
        XCTAssertEqual(pagination.nextOffset, 10)
    }

    func testNextOffset_10_nil() {
        let pagination = CollectionResponse<String>.Pagination(total: 11, offset: 10, limit: 5)
        XCTAssertNil(pagination.nextOffset)
    }
}
