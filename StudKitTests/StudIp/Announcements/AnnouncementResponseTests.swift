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

import CoreData
@testable import StudKit
import XCTest

final class AnnouncementResponseTests: XCTestCase {
    private let decoder = ServiceContainer.default[JSONDecoder.self]
    private var context: NSManagedObjectContext!
    private lazy var organization = try! OrganizationRecord(id: "O0").coreDataObject(in: context)

    // MARK: - Life Cycle

    override func setUp() {
        context = StudKitTestsServiceProvider(context: Targets.Context(currentTarget: .tests))
            .provideCoreDataService().viewContext

        try! CourseResponse(id: "C0").coreDataObject(organization: organization, in: context)
        try! CourseResponse(id: "C1").coreDataObject(organization: organization, in: context)

        try! UserResponse(id: "U0").coreDataObject(organization: organization, in: context)
    }

    // MARK: - Coding

    func testInit_Announcement0() {
        let announcement = try! decoder.decode(AnnouncementResponse.self, from: AnnouncementResponseTests.announcement0Data)
        XCTAssertEqual(announcement.id, "A0")
        XCTAssertEqual(announcement.courseIds, ["C0"])
        XCTAssertEqual(announcement.userId, "U0")
        XCTAssertEqual(announcement.createdAt.debugDescription, "2017-12-12 11:48:42 +0000")
        XCTAssertEqual(announcement.modifiedAt.debugDescription, "2017-12-12 11:48:42 +0000")
        XCTAssertEqual(announcement.title, "Weihnachtspause")
        XCTAssertEqual(announcement.textContent, "Liebe Studierende,\r\n\r\ndies ist ein Test.")
    }

    func testInit_Announcement1() {
        let announcement = try! decoder.decode(AnnouncementResponse.self, from: AnnouncementResponseTests.announcement1Data)
        XCTAssertEqual(announcement.id, "A1")
        XCTAssertEqual(announcement.courseIds, ["C0", "C1"])
        XCTAssertEqual(announcement.userId, nil)
        XCTAssertEqual(announcement.createdAt.debugDescription, "2017-12-12 11:48:42 +0000")
        XCTAssertEqual(announcement.modifiedAt.debugDescription, "2017-12-12 11:48:42 +0000")
        XCTAssertEqual(announcement.title, "Title")
        XCTAssertEqual(announcement.textContent, "Another test.")
    }

    func testInit_AnnouncementCollection() {
        let collection = try! decoder.decode(CollectionResponse<AnnouncementResponse>.self, fromResource: "announcementCollection")
        XCTAssertEqual(collection.items.count, 2)
    }

    // MARK: - Converting to a Core Data Object

    func testCoreDataObject_Announcement0() {
        let announcement = try! AnnouncementResponseTests.announcement0.coreDataObject(organization: organization, in: context)
        XCTAssertEqual(announcement.id, "A0")
        XCTAssertEqual(Set(announcement.courses.map { $0.id }), ["C0", "C1"])
        XCTAssertEqual(announcement.user?.id, "U0")
        XCTAssertEqual(announcement.createdAt, Date(timeIntervalSince1970: 1))
        XCTAssertEqual(announcement.modifiedAt, Date(timeIntervalSince1970: 2))
        XCTAssertEqual(announcement.expiresAt, Date(timeIntervalSince1970: 4))
        XCTAssertEqual(announcement.title, "Title")
        XCTAssertEqual(announcement.htmlContent, "Body")
    }
}
