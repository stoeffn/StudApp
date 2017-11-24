//
//  RangeIteratorTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 11.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import XCTest
@testable import StudKit

final class RangeIteratorTests: XCTestCase {
    struct TestDataSourceSection: DataSourceSection {
        typealias Row = Int

        weak var delegate: DataSourceSectionDelegate?

        var numberOfRows = 3

        subscript(rowAt index: Int) -> Int {
            return index
        }
    }

    func test_Range_Iterated() {
        var iterator = RangeIterator(range: -2 ..< 2) { $0 }
        XCTAssertEqual(iterator.next(), -2)
        XCTAssertEqual(iterator.next(), -1)
        XCTAssertEqual(iterator.next(), 0)
        XCTAssertEqual(iterator.next(), 1)
        XCTAssertEqual(iterator.next(), nil)
    }

    func test_DataSourceSection_Iterated() {
        let testDataSourceSection = TestDataSourceSection()
        var iterator = testDataSourceSection.makeIterator()
        XCTAssertEqual(iterator.next(), 0)
        XCTAssertEqual(iterator.next(), 1)
        XCTAssertEqual(iterator.next(), 2)
        XCTAssertEqual(iterator.next(), nil)
    }
}
