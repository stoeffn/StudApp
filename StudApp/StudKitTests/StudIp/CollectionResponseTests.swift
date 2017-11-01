//
//  CollectionResponseTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 17.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import XCTest
@testable import StudKit

final class CollectionResponseTests : XCTestCase {
    let decoder = ServiceContainer.default[JSONDecoder.self]
    let data = """
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
