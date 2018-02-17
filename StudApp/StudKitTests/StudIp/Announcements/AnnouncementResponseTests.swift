//
//  AnnouncementResponseTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 15.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import XCTest
@testable import StudKit

final class AnnouncementResponseTests: XCTestCase {
    let decoder = ServiceContainer.default[JSONDecoder.self]
    var context: NSManagedObjectContext!

    // MARK: - Life Cycle

    override func setUp() {
        context = StudKitTestsServiceProvider(currentTarget: .tests).provideCoreDataService().viewContext

        try! CourseResponse(id: "C0").coreDataObject(in: context)
        try! CourseResponse(id: "C1").coreDataObject(in: context)
    }

    // MARK: - Coding

    func testInit_Announcement0() {
        let announcement = try! decoder.decode(AnnouncementResponse.self, from: AnnouncementResponseTests.announcement0Data)
        XCTAssertEqual(announcement.id, "A0")
        XCTAssertEqual(announcement.courseIds, ["C0"])
        XCTAssertEqual(announcement.userId, "U0")
        XCTAssertEqual(announcement.createdAt.debugDescription, "2017-12-12 11:48:42 +0000")
        XCTAssertEqual(announcement.modifiedAt.debugDescription, "2017-12-12 11:48:42 +0000")
        XCTAssertEqual(announcement.expiresAt.debugDescription, "2018-01-09 11:47:42 +0000")
        XCTAssertEqual(announcement.title, "Weihnachtspause")
        XCTAssertEqual(announcement.body, "Liebe Studierende,\r\n\r\ndies ist ein Test.")
    }

    func testInit_Announcement1() {
        let announcement = try! decoder.decode(AnnouncementResponse.self, from: AnnouncementResponseTests.announcement1Data)
        XCTAssertEqual(announcement.id, "A1")
        XCTAssertEqual(announcement.courseIds, ["C0", "C1"])
        XCTAssertEqual(announcement.userId, nil)
        XCTAssertEqual(announcement.createdAt.debugDescription, "2017-12-12 11:48:42 +0000")
        XCTAssertEqual(announcement.modifiedAt.debugDescription, "2017-12-12 11:48:42 +0000")
        XCTAssertEqual(announcement.expiresAt.debugDescription, "2018-01-09 11:47:42 +0000")
        XCTAssertEqual(announcement.title, "Title")
        XCTAssertEqual(announcement.body, "Another test.")
    }

    func testInit_AnnouncementCollection() {
        let collection = try! decoder.decode(CollectionResponse<AnnouncementResponse>.self, fromResource: "announcementCollection")
        XCTAssertEqual(collection.items.count, 2)
    }

    // MARK: - Converting to a Core Data Object

    func testCoreDataObject_Announcement0() {
        let announcement = try! AnnouncementResponseTests.announcement0.coreDataObject(in: context)
        XCTAssertEqual(announcement.id, "A0")
        XCTAssertEqual(Set(announcement.courses.map { $0.id }), ["C0", "C1"])
        XCTAssertEqual(announcement.user?.id, "U0")
        XCTAssertEqual(announcement.createdAt, Date(timeIntervalSince1970: 1))
        XCTAssertEqual(announcement.modifiedAt, Date(timeIntervalSince1970: 2))
        XCTAssertEqual(announcement.expiresAt, Date(timeIntervalSince1970: 4))
        XCTAssertEqual(announcement.title, "Title")
        XCTAssertEqual(announcement.body, "Body")
    }
}
