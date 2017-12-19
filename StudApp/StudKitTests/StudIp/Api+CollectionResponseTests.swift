//
//  Api+CollectionResponseTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 27.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import XCTest
@testable import StudKit

final class ApiCollectionResponseTests: XCTestCase {
    private let api = MockApi<TestRoutes>(baseUrl: URL(string: "https://example.com")!)

    func testRequestCollection_Request0_Response0() {
        api.requestCollectionPage(.collection) { (result: Result<CollectionResponse<Test>>) in
            XCTAssertTrue(result.isSuccess)
            XCTAssertEqual(result.value?.items.count, 1)
            XCTAssertEqual(result.value?.items.first?.id, "0")
            XCTAssertEqual(result.value?.pagination.offset, 0)
            XCTAssertEqual(result.value?.pagination.limit, 5)
        }
    }

    func testRequestCollection_Request5_Response5() {
        api.requestCollectionPage(.collection, afterOffset: 5, itemsPerRequest: 5) { (result: Result<CollectionResponse<Test>>) in
            XCTAssertTrue(result.isSuccess)
            XCTAssertEqual(result.value?.items.count, 1)
            XCTAssertEqual(result.value?.items.first?.id, "1")
            XCTAssertEqual(result.value?.pagination.offset, 5)
            XCTAssertEqual(result.value?.pagination.limit, 5)
        }
    }

    func testRequestCompleteCollection_Request5_Response() {
        let items = [Test(id: "0")]
        api.requestCollection(.collection, afterOffset: 5, itemsPerRequest: 5, items: items) { (result: Result<[Test]>) in
            XCTAssertTrue(result.isSuccess)
            XCTAssertEqual(result.value?.count, 3)
            XCTAssertEqual(result.value?.first?.id, "0")
            XCTAssertEqual(result.value?.last?.id, "2")
        }
    }

    func testRequestCompleteCollection_Request10_Response() {
        let items = [Test(id: "0"), Test(id: "1")]
        api.requestCollection(.collection, afterOffset: 10, itemsPerRequest: 5, items: items) { (result: Result<[Test]>) in
            XCTAssertTrue(result.isSuccess)
            XCTAssertEqual(result.value?.count, 3)
            XCTAssertEqual(result.value?.first?.id, "0")
            XCTAssertEqual(result.value?.last?.id, "2")
        }
    }

    func testRequestCompleteCollection_Request_Response() {
        api.requestCollection(.collection, itemsPerRequest: 5) { (result: Result<[Test]>) in
            XCTAssertTrue(result.isSuccess)
            XCTAssertEqual(result.value?.count, 3)
            XCTAssertEqual(result.value?.first?.id, "0")
            XCTAssertEqual(result.value?.last?.id, "2")
        }
    }

    func testRequestCompleteCollection_Request_Failure() {
        api.requestCollection(.failingCollection, itemsPerRequest: 5) { (result: Result<[Test]>) in
            XCTAssertTrue(result.isFailure)
        }
    }
}
