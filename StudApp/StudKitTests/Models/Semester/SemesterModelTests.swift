//
//  SemesterModelTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 08.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import XCTest
@testable import StudKit

final class SemesterModelTests: XCTestCase {
    let decoder = ServiceContainer.default[JSONDecoder.self]

    func testInit_SemesterData_Semester() {
        let semester = try! decoder.decode(SemesterModel.self, from: SemesterModelTests.semesterData)
        XCTAssertEqual(semester.id, "1")
        XCTAssertEqual(semester.title, "SS 2009")
        XCTAssertEqual(semester.beginDate.description, "2009-03-29 22:00:00 +0000")
        XCTAssertEqual(semester.endDate.description, "2009-09-30 21:59:59 +0000")
        XCTAssertEqual(semester.coursesBeginDate.description, "2009-03-29 22:00:00 +0000")
        XCTAssertEqual(semester.coursesEndDate.description, "2009-07-04 21:59:59 +0000")
    }
}
