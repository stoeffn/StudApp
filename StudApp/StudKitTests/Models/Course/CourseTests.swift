//
//  CourseTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 25.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import XCTest
@testable import StudKit

final class CourseTests : XCTestCase {
    var context: NSManagedObjectContext!

    override func setUp() {
        context = StudKitTestsServiceProvider().provideCoreDataService().viewContext

        try! SemesterModel(id: "0", title: "Semester", beginDate: Date(timeIntervalSince1970: 0),
                           endDate: Date(timeIntervalSince1970: 9), coursesBeginDate: .distantPast,
                           coursesEndDate: .distantFuture).coreDataModel(in: context)
        try! SemesterModel(id: "1", title: "Semester", beginDate: Date(timeIntervalSince1970: 10),
                           endDate: Date(timeIntervalSince1970: 19), coursesBeginDate: .distantPast,
                           coursesEndDate: .distantFuture).coreDataModel(in: context)

        try! CourseModel(id: "0", title: "A", beginSemesterPath: "/0", endSemesterPath: "/0").coreDataModel(in: context)
        try! CourseModel(id: "1", title: "B", beginSemesterPath: "/0", endSemesterPath: "/0").coreDataModel(in: context)
        try! CourseModel(id: "2", title: "C", beginSemesterPath: "/0", endSemesterPath: "/1").coreDataModel(in: context)
        try! CourseModel(id: "3", title: "D", beginSemesterPath: "/1", endSemesterPath: "/1").coreDataModel(in: context)

        try! FileModel(folderId: "0", coursePath: "/0", title: "A").coreDataModel(in: context)
        try! FileModel(fileId: "1", name: "1", coursePath: "/0", title: "B").coreDataModel(in: context)
        try! FileModel(fileId: "2", name: "2", coursePath: "/0", parentId: "0", title: "C").coreDataModel(in: context)
        try! FileModel(fileId: "3", name: "3", coursePath: "/1", title: "D").coreDataModel(in: context)
    }

    func testInit_CourseModel_Course() {
        let course = try! CourseModel(id: "0", rawNumber: " 123  ", title: "Title", subtitle: "Subtitle",
                                      location: "Location", rawSummary: "Summary<br> ",
                                      rawLecturers: ["abc": UserModelTests.user], beginSemesterPath: "/0",
                                      endSemesterPath: "/0")
            .coreDataModel(in: context) as! Course
        
        XCTAssertEqual(course.id, "0")
        XCTAssertEqual(course.number, "123")
        XCTAssertEqual(course.title, "Title")
        XCTAssertEqual(course.subtitle, "Subtitle")
        XCTAssertEqual(course.summary, "Summary")
        XCTAssertEqual(course.location, "Location")
        XCTAssertEqual(course.lecturers.count, 1)
        XCTAssertEqual(course.lecturers.first?.id, "0")
        XCTAssertNotNil(course.state)
        XCTAssertEqual(course.semesters.count, 1)
        XCTAssertEqual(course.semesters.first?.title, "Semester")
    }

    func testBySemester_0_3Courses() {
        let semester = try! Semester.fetch(byId: "0", in: context)
        let courses = try! context.fetch(semester!.coursesFetchRequest)
        XCTAssertEqual(courses.map { $0.course.id }.set, Set(arrayLiteral: "0", "1", "2"))
    }

    func testBySemester_1_2Courses() {
        let semester = try! Semester.fetch(byId: "1", in: context)
        let courses = try! context.fetch(semester!.coursesFetchRequest)
        XCTAssertEqual(courses.map { $0.course.id }.set, Set(arrayLiteral: "2", "3"))
    }

    func testFetchFiles_Course1_Files() {
        let course = try! Course.fetch(byId: "0", in: context)
        let rootFiles = try! course?.fetchFiles(in: context)
        XCTAssertNotNil(course)
        XCTAssertNotNil(rootFiles)
        XCTAssertEqual(rootFiles?.count, 2)
    }

    func testFetchFiles_Course2_Files() {
        let course = try! Course.fetch(byId: "1", in: context)
        let rootFiles = try! course?.fetchFiles(in: context)
        XCTAssertNotNil(course)
        XCTAssertNotNil(rootFiles)
        XCTAssertEqual(rootFiles?.count, 1)
    }

    func testFetchFiles_Course3_Empty() {
        let course = try! Course.fetch(byId: "2", in: context)
        let rootFiles = try! course?.fetchFiles(in: context)
        XCTAssertNotNil(course)
        XCTAssertNotNil(rootFiles)
        XCTAssertTrue(rootFiles?.isEmpty ?? false)
    }
}
