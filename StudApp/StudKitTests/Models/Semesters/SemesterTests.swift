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

final class SemesterTests: XCTestCase {
    private let decoder = ServiceContainer.default[JSONDecoder.self]
    private var context: NSManagedObjectContext!
    private lazy var organization = try! OrganizationRecord(id: "O0").coreDataObject(in: context)

    // MARK: - Life Cycle

    override func setUp() {
        context = StudKitTestsServiceProvider(currentTarget: .tests).provideCoreDataService().viewContext

        try! SemesterResponse(id: "S0", beginsAt: Date(timeIntervalSince1970: 0), endsAt: Date(timeIntervalSince1970: 9))
            .coreDataObject(organization: organization, in: context)
        try! SemesterResponse(id: "S1", beginsAt: Date(timeIntervalSince1970: 10), endsAt: Date(timeIntervalSince1970: 19))
            .coreDataObject(organization: organization, in: context)
        try! SemesterResponse(id: "S2", beginsAt: Date(timeIntervalSince1970: 20), endsAt: Date(timeIntervalSince1970: 29))
            .coreDataObject(organization: organization, in: context)
        try! SemesterResponse(id: "S3", beginsAt: Date(timeIntervalSince1970: 30), endsAt: Date(timeIntervalSince1970: 39))
            .coreDataObject(organization: organization, in: context)

        try! CourseResponse(id: "C0", beginSemesterId: "S2").coreDataObject(organization: organization, in: context)
    }

    // MARK: - Fetching

    func testFetchFrom_1to2_12() {
        let from = try! Semester.fetch(byId: "S1", in: context)
        let to = try! Semester.fetch(byId: "S2", in: context)
        let semesters = try! organization.fetchSemesters(from: from!, to: to, in: context)
        XCTAssertEqual(Set(semesters.map { $0.id }), ["S1", "S2"])
    }

    func testFetchFrom_1to3_123() {
        let from = try! Semester.fetch(byId: "S1", in: context)
        let to = try! Semester.fetch(byId: "S3", in: context)
        let semesters = try! organization.fetchSemesters(from: from!, to: to, in: context)
        XCTAssertEqual(Set(semesters.map { $0.id }), ["S1", "S2", "S3"])
    }

    func testFetchFrom_2_23() {
        let from = try! Semester.fetch(byId: "S2", in: context)
        let semesters = try! organization.fetchSemesters(from: from!, in: context)
        XCTAssertEqual(Set(semesters.map { $0.id }), ["S2", "S3"])
    }
}
