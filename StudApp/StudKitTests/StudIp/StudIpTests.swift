//
//  StudIpTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 04.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import XCTest
@testable import StudKit

final class TransformsTests: XCTestCase {
    // MARK: - Transforming Id Paths

    func testTransformIdPath_IdPath() {
        XCTAssertEqual(StudIp.transform(idPath: "/api.php/semester/1927f2b86d6b185aa6c6697810ad42f1"),
                       "1927f2b86d6b185aa6c6697810ad42f1")
    }

    func testTransformIdPath_IdPathWithNews() {
        XCTAssertEqual(StudIp.transform(idPath: "/api.php/semester/464da3a21f36a104787474b7d608137e/news"),
                       "464da3a21f36a104787474b7d608137e")
    }

    func testTransformIdPath_IdPathWithoutSlash() {
        XCTAssertEqual(StudIp.transform(idPath: "api.php/semester/b51cd33ccd3d7355b3fd317ab7bef001"),
                       "b51cd33ccd3d7355b3fd317ab7bef001")
    }

    func testTransformIdPath_InvalidPath() {
        XCTAssertEqual(StudIp.transform(idPath: "/api.php/semester/"), nil)
    }

    func testTransformIdPath_ShortForm() {
        XCTAssertEqual(StudIp.transform(idPath: "U20"), "U20")
    }

    func testTransformIdPath_ShortFormInPath() {
        XCTAssertEqual(StudIp.transform(idPath: "U20"), "U20")
    }

    // MARK: - Transforming Course Numbers

    func testTransformCourseNumber_Padding() {
        XCTAssertEqual(StudIp.transform(courseNumber: "   123 "), "123")
    }

    func testTransformCourseNumber_Whitespace() {
        XCTAssertEqual(StudIp.transform(courseNumber: "    "), nil)
    }

    // MARK: - Transforming Course Summaries

    func testTransformCourseSummary_Tag() {
        XCTAssertEqual(StudIp.transform(courseSummary: "Test <b>&#64;abc</b> "), "Test @abc")
    }

    func testTransformCourseSummary_Literature() {
        XCTAssertEqual(StudIp.transform(courseSummary: "Test Literatur: "), "Test")
    }

    func testTransformCourseSummary_Html() {
        XCTAssertEqual(StudIp.transform(courseSummary: "Hall&ouml;chen"), "Hallöchen")
    }

    func testTransformCourseSummary_Complex() {
        XCTAssertEqual(StudIp.transform(courseSummary: " <strong>  T&ouml;st</strong> Literatur: "), "Töst")
    }

    // MARK: - Transforming Locations

    func testTransformLocation_Whitespace() {
        XCTAssertEqual(StudIp.transform(location: " Room E001  "), "Room E001")
    }

    func testTransformLocation_Parenthesis() {
        XCTAssertEqual(StudIp.transform(location: " (Room E001 )"), "Room E001")
    }

    func testTransformLocation_Building() {
        XCTAssertEqual(StudIp.transform(location: " (Room E001 Gebaeude Test )"), "Room E001 Gebäude Test")
    }

    func testTransformLocation_LineBreaks() {
        XCTAssertEqual(StudIp.transform(location: " (Room E001 ,  Gebaeude Test )"), "Room E001\nGebäude Test")
    }
}
