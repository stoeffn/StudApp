//
//  CDIdentifiableTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 28.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import XCTest
@testable import StudKit

final class CDIdentifiableTests: XCTestCase {
    var context: NSManagedObjectContext!

    // MARK: - Life Cycle

    override func setUp() {
        context = StudKitTestsServiceProvider(currentTarget: .tests).provideCoreDataService().viewContext

        try! CourseResponse(id: "C0").coreDataObject(in: context)
        try! CourseResponse(id: "C1").coreDataObject(in: context)
        try! CourseResponse(id: "C2").coreDataObject(in: context)
    }

    // MARK: - Fetching by Id

    func testFetchById_ExistingId() {
        let course = try! Course.fetch(byId: "C0", in: context)
        XCTAssertEqual(course?.id, "C0")
    }

    func testFetchById_MissingId() {
        let course = try! Course.fetch(byId: "abc", in: context)
        XCTAssertNil(course)
    }

    func testFetchById_Nil() {
        let course = try! Course.fetch(byId: nil, in: context)
        XCTAssertNil(course)
    }

    // MARK: - Fetching by Multiple Ids

    func testFetchByIds_Courses() {
        let courses = try! Course.fetch(byIds: ["C0", "C2"], in: context)
        XCTAssertEqual(Set(courses.map { $0.id }), ["C0", "C2"])
    }

    // MARK: - Fetching by Id or Creating

    func testFetchByIdOrCreate_ExistingId() {
        let (course, isNew) = try! Course.fetch(byId: "C0", orCreateIn: context)
        XCTAssertFalse(isNew)
        XCTAssertEqual(course.id, "C0")
    }

    func testFetchByIdOrCreate_MissingId() {
        let (course, isNew) = try! Course.fetch(byId: "abc", orCreateIn: context)
        XCTAssertTrue(isNew)
        XCTAssertEqual(course.id, "abc")
    }

    // MARK: - Managing Object Identifiers

    func testObjectIdentifier() {
        let course3 = try! CourseResponse(id: "C3").coreDataObject(in: context)
        XCTAssertEqual(course3.objectIdentifier.entity, .course)
        XCTAssertEqual(course3.objectIdentifier.id, "C3")
    }

    func testFetchByObjectId_ExistingId() {
        let course = Course.fetch(byObjectId: ObjectIdentifier(entity: .course, id: "C0"), in: context)
        XCTAssertEqual(course?.id, "C0")
    }

    func testFetchByObjectId_WrongEntity() {
        let course = Course.fetch(byObjectId: ObjectIdentifier(entity: .user, id: "U0"), in: context)
        XCTAssertNil(course)
    }

    func testFetchByObjectId_MissingId() {
        let course = Course.fetch(byObjectId: ObjectIdentifier(entity: .course, id: "abc"), in: context)
        XCTAssertNil(course)
    }

    func testFetchByObjectId_Nil() {
        let course = Course.fetch(byObjectId: nil, in: context)
        XCTAssertNil(course)
    }
}
