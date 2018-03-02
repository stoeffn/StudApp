//
//  CDIdentifiableTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 28.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
@testable import StudKit
import XCTest

final class CDIdentifiableTests: XCTestCase {
    private var context: NSManagedObjectContext!
    private lazy var organization = try! OrganizationRecord(id: "O0").coreDataObject(in: context)

    // MARK: - Life Cycle

    override func setUp() {
        context = StudKitTestsServiceProvider(currentTarget: .tests).provideCoreDataService().viewContext

        try! CourseResponse(id: "C0").coreDataObject(organization: organization, in: context)
        try! CourseResponse(id: "C1", title: "scope").coreDataObject(organization: organization, in: context)
        try! CourseResponse(id: "C2", title: "scope").coreDataObject(organization: organization, in: context)
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
        let course3 = try! CourseResponse(id: "C3").coreDataObject(organization: organization, in: context)
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

    // MARK: - Updating Objects

    func testUpdate_Empty() {
        try! Course.update(Course.fetchRequest(), with: [CourseResponse](), in: context) {
            try $0.coreDataObject(organization: organization, in: context)
        }
        XCTAssertEqual(try! Course.fetch(in: context).count, 0)
    }

    func testUpdate_Add() {
        let responses = [CourseResponse(id: "C3"), CourseResponse(id: "C4")]
        try! Course.update(Course.fetchRequest(), with: responses, in: context) {
            try $0.coreDataObject(organization: organization, in: context)
        }
        let courses = try! Course.fetch(in: context)
        XCTAssertEqual(Set(courses.map { $0.id }), ["C3", "C4"])
    }

    func testUpdate_AddWithoutDeleting() {
        let responses = [CourseResponse(id: "C3"), CourseResponse(id: "C4")]
        try! Course.update(with: responses, in: context) {
            try $0.coreDataObject(organization: organization, in: context)
        }
        let courses = try! Course.fetch(in: context)
        XCTAssertEqual(Set(courses.map { $0.id }), ["C0", "C1", "C2", "C3", "C4"])
    }

    func testUpdate_AddAndUpdate() {
        let responses = [CourseResponse(id: "C1"), CourseResponse(id: "C2"), CourseResponse(id: "C3"), CourseResponse(id: "C4")]
        try! Course.update(Course.fetchRequest(), with: responses, in: context) {
            try $0.coreDataObject(organization: organization, in: context)
        }
        let courses = try! Course.fetch(in: context)
        XCTAssertEqual(Set(courses.map { $0.id }), ["C1", "C2", "C3", "C4"])
    }

    func testUpdate_AddAndUpdateSubset() {
        let fetchRequest = Course.fetchRequest(predicate: NSPredicate(format: "title == %@", "scope"))
        let responses = [CourseResponse(id: "C1"), CourseResponse(id: "C2"), CourseResponse(id: "C3"), CourseResponse(id: "C4")]
        try! Course.update(fetchRequest, with: responses, in: context) {
            try $0.coreDataObject(organization: organization, in: context)
        }
        let courses = try! Course.fetch(in: context)
        XCTAssertEqual(Set(courses.map { $0.id }), ["C0", "C1", "C2", "C3", "C4"])
    }
}
