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

final class OrganizationStudIpTests: XCTestCase {
    private var context: NSManagedObjectContext!
    private lazy var organization = try! OrganizationRecord(id: "O0").coreDataObject(in: context)

    // MARK: - Life Cycle

    override func setUp() {
        context = StudKitTestsServiceProvider(context: Targets.Context(currentTarget: .tests))
            .provideCoreDataService().viewContext

        try! SemesterResponse(id: "135de7259e0862cbcd3878e038253776").coreDataObject(organization: organization, in: context)
    }

    // MARK: - Updating Semesters

    func testUpdate_SemesterCollectionResponse() {
        organization.updateSemesters { result in
            let semester = try! Semester.fetch(byId: "135de7259e0862cbcd3878e038253776", in: self.context)
            XCTAssertTrue(result.isSuccess)
            XCTAssertEqual(try! Semester.fetch(in: self.context).count, 20)
            XCTAssertEqual(semester?.title, "WS 2008/09")
        }
    }
}
