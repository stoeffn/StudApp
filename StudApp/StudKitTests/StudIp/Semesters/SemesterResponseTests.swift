//
//  SemesterResponseTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 08.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import XCTest
@testable import StudKit

final class SemesterResponseTests: XCTestCase {
    let decoder = ServiceContainer.default[JSONDecoder.self]

    func testInit_SemesterData_Semester() {
        let semester = try! decoder.decode(SemesterResponse.self, from: SemesterResponseTests.semesterData)
        XCTAssertEqual(semester.id, "1")
        XCTAssertEqual(semester.title, "SS 2009")
        XCTAssertEqual(semester.beginsAt.description, "2009-03-29 22:00:00 +0000")
        XCTAssertEqual(semester.endsAt.description, "2009-09-30 21:59:59 +0000")
        XCTAssertEqual(semester.coursesBeginAt.description, "2009-03-29 22:00:00 +0000")
        XCTAssertEqual(semester.coursesEndAt.description, "2009-07-04 21:59:59 +0000")
    }
}
