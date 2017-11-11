//
//  TransformsTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 04.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import XCTest
@testable import StudKit

final class TransformsTests: XCTestCase {
    func testTransformIdpath_IdPath_Id() {
        XCTAssertEqual(StudIp.transformIdPath("/api.php/semester/123"), "123")
    }

    func testTransformIdpath_InvalidPath_Nil() {
        XCTAssertEqual(StudIp.transformIdPath("/api.php/semester/"), nil)
    }

    func testTransformCourseNumber_Padding_Trimmed() {
        XCTAssertEqual(StudIp.transformCourseNumber("   123 "), "123")
    }

    func testTransformCourseNumber_Whitespace_Nil() {
        XCTAssertEqual(StudIp.transformCourseNumber("    "), nil)
    }

    func testTransformCourseSummary_Tag_Replaced() {
        XCTAssertEqual(StudIp.transformCourseSummary("Test <b>&#64;abc</b> "), "Test @abc")
    }

    func testTransformCourseSummary_Literature_Replaced() {
        XCTAssertEqual(StudIp.transformCourseSummary("Test Literatur: "), "Test")
    }

    func testTransformCourseSummary_Html_Decoded() {
        XCTAssertEqual(StudIp.transformCourseSummary("Hall&ouml;chen"), "Hallöchen")
    }

    func testTransformCourseSummary_Complex_Cleaned() {
        XCTAssertEqual(StudIp.transformCourseSummary(" <strong>  T&ouml;st</strong> Literatur: "), "Töst")
    }
}
