//
//  CourseResponseTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 24.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import XCTest
@testable import StudKit

final class CourseResponseTests: XCTestCase {
    let decoder = ServiceContainer.default[JSONDecoder.self]

    func testInit_CourseData_Course() {
        let course = try! decoder.decode(CourseResponse.self, from: CourseResponseTests.courseData)
        XCTAssertEqual(course.id, "0")
        XCTAssertEqual(course.number, "10062")
        XCTAssertEqual(course.title, "Title")
        XCTAssertEqual(course.subtitle, "Subtitle")
        XCTAssertEqual(course.summary, "Sümmary")
        XCTAssertEqual(course.location, "Location")
        XCTAssertEqual(course.lecturers.count, 1)
        XCTAssertEqual(course.lecturers.first?.id, "0")
        XCTAssertEqual(course.beginSemesterId, "0")
        XCTAssertEqual(course.endSemesterId, "1")
    }

    func testInit_CourseCollection_Courses() {
        let collection = try! decoder.decode(CollectionResponse<CourseResponse>.self, fromResource: "courseCollection")
        XCTAssertEqual(collection.items.count, 20)
    }
}
