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
