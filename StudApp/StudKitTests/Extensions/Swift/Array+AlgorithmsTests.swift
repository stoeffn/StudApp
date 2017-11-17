//
//  Array+AlgorithmsTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 17.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import XCTest
@testable import StudKit

final class ArrayAlgorithmsTests: XCTestCase {
    func testFirstCommonElement_Empty_nil() {
        let element = [].firstCommonElement(type: String.self)
        XCTAssertNil(element)
    }

    func testFirstCommonElement_EmptyArrays_nil() {
        let element = [[], [], []].firstCommonElement(type: String.self)
        XCTAssertNil(element)
    }

    func testFirstCommonElement_OneElement_a() {
        let element = [["a"]].firstCommonElement(type: String.self)
        XCTAssertEqual("a", element)
    }

    func testFirstCommonElement_OneElementAndEmptyArray_a() {
        let element = [["a"], []].firstCommonElement(type: String.self)
        XCTAssertNil(element)
    }

    func testFirstCommonElement_OneElementInTwoArrays_a() {
        let element = [["a"], ["a"]].firstCommonElement(type: String.self)
        XCTAssertEqual("a", element)
    }

    func testFirstCommonElement_Strings_e() {
        let element = [
            ["y", "g", "e", "b"],
            ["e", "b", "f"],
            ["g", "e", "b", "d", "x"],
        ].firstCommonElement(type: String.self)
        XCTAssertEqual("e", element)
    }

    func testFirstCommonElement_Strings_nil() {
        let element = [
            ["y", "g", "e", "b"],
            ["e", "b", "f"],
            ["g", "b", "d", "x"],
        ].firstCommonElement(type: String.self)
        XCTAssertNil(element)
    }

    func testFirstCommonElement_StringsAsInt_nil() {
        let element = [
            ["y", "g", "e", "b"],
            ["e", "b", "f"],
            ["g", "e", "b", "d", "x"],
        ].firstCommonElement(type: Int.self)
        XCTAssertNil(element)
    }
}
