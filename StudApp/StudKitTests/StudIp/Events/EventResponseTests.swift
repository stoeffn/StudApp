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

final class EventResponseTests: XCTestCase {
    private let decoder = ServiceContainer.default[JSONDecoder.self]
    private var context: NSManagedObjectContext!
    private lazy var organization = try! OrganizationRecord(id: "O0").coreDataObject(in: context)

    // MARK: - Life Cycle

    override func setUp() {
        context = StudKitTestsServiceProvider(context: Targets.Context(currentTarget: .tests))
            .provideCoreDataService().viewContext
    }

    // MARK: - Coding

    func testInit_EventData_Event() {
        let event = try! decoder.decode(EventResponse.self, from: EventResponseTests.eventData)
        XCTAssertEqual(event.id, "0")
        XCTAssertEqual(event.startsAt.debugDescription, "2016-11-03 15:30:00 +0000")
        XCTAssertEqual(event.endsAt.debugDescription, "2016-11-03 17:00:00 +0000")
        XCTAssertFalse(event.isCanceled)
        XCTAssertNil(event.cancellationReason)
        XCTAssertEqual(event.summary, "Sümmary")
        XCTAssertEqual(event.location, "Raum 023: Multimedia-Hörsaal\nGebäude 3703: Technische Informatik")
        XCTAssertEqual(event.category, "Sitzung")
    }

    func testInit_CanceledEventData_Event() {
        let event = try! decoder.decode(EventResponse.self, from: EventResponseTests.canceledEventData)
        XCTAssertEqual(event.id, "1")
        XCTAssertEqual(event.startsAt.debugDescription, "2017-02-03 14:15:00 +0000")
        XCTAssertEqual(event.endsAt.debugDescription, "2017-02-03 15:45:00 +0000")
        XCTAssertTrue(event.isCanceled)
        XCTAssertNil(event.cancellationReason)
        XCTAssertNil(event.summary)
        XCTAssertNil(event.location)
        XCTAssertEqual(event.category, "Sitzung")
    }

    func testInit_CanceledEventWithReasonData_Event() {
        let event = try! decoder.decode(EventResponse.self, from: EventResponseTests.canceledEventWithReasonData)
        XCTAssertEqual(event.id, "2")
        XCTAssertEqual(event.startsAt.debugDescription, "2017-01-05 15:30:00 +0000")
        XCTAssertEqual(event.endsAt.debugDescription, "2017-01-05 17:00:00 +0000")
        XCTAssertTrue(event.isCanceled)
        XCTAssertEqual(event.cancellationReason, "Weihnachtsferien 2016")
        XCTAssertNil(event.summary)
        XCTAssertNil(event.location)
        XCTAssertEqual(event.category, "Sitzung")
    }

    func testInit_EventCollection_Events() {
        let collection = try! decoder.decode(CollectionResponse<EventResponse>.self, fromResource: "eventCollection")
        XCTAssertEqual(collection.items.count, 63)
    }

    // MARK: - Converting to a Core Data Object

    func testCoreDataObject_Event0() {
        let course = try! CourseResponse(id: "C0").coreDataObject(organization: organization, in: context)
        let event = try! EventResponseTests.event0.coreDataObject(course: course, in: context)
        XCTAssertEqual(event.id, "E0")
        XCTAssertEqual(event.course.id, "C0")
        XCTAssertEqual(event.startsAt, Date(timeIntervalSince1970: 1))
        XCTAssertEqual(event.endsAt, Date(timeIntervalSince1970: 2))
        XCTAssertTrue(event.isCanceled)
        XCTAssertEqual(event.cancellationReason, "Reason")
        XCTAssertEqual(event.location, "Location")
        XCTAssertEqual(event.summary, "Summary")
        XCTAssertEqual(event.category, "Category")
    }
}
