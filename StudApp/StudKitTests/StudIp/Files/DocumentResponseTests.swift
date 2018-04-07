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
import MobileCoreServices
@testable import StudKit
import XCTest

final class DocumentResponseTests: XCTestCase {
    private let decoder = ServiceContainer.default[JSONDecoder.self]
    private var context: NSManagedObjectContext!
    private lazy var organization = try! OrganizationRecord(id: "O0").coreDataObject(in: context)

    // MARK: - Life Cycle

    override func setUp() {
        context = StudKitTestsServiceProvider(currentTarget: .tests).provideCoreDataService().viewContext

        try! UserResponse(id: "U0").coreDataObject(organization: organization, in: context)
    }

    // MARK: - Coding

    func testInit_Document0Data() {
        let document = try! decoder.decode(DocumentResponse.self, from: DocumentResponseTests.document0Data)
        XCTAssertEqual(document.id, "F0")
        XCTAssertEqual(document.location, .studIp)
        XCTAssertNil(document.externalUrl)
        XCTAssertEqual(document.userId, "U0")
        XCTAssertEqual(document.name, "variante_B_04.png")
        XCTAssertEqual(document.createdAt.debugDescription, "2014-03-21 18:31:58 +0000")
        XCTAssertEqual(document.modifiedAt.debugDescription, "2014-03-21 18:31:58 +0000")
        XCTAssertEqual(document.summary, "Sümmary")
        XCTAssertEqual(document.downloadCount, 64)
        XCTAssertEqual(document.size, 1024)
        XCTAssertEqual(document.typeIdentifier, kUTTypePNG as String)
    }

    func testInit_Document1Data() {
        let document = try! decoder.decode(DocumentResponse.self, from: DocumentResponseTests.document1Data)
        XCTAssertEqual(document.id, "F1")
        XCTAssertEqual(document.location, .studIp)
        XCTAssertNil(document.externalUrl)
        XCTAssertNil(document.userId)
        XCTAssertEqual(document.name, "variante_B_04.png")
        XCTAssertEqual(document.createdAt.debugDescription, "2014-03-21 18:31:58 +0000")
        XCTAssertEqual(document.modifiedAt.debugDescription, "2014-03-21 18:31:58 +0000")
        XCTAssertNil(document.summary)
        XCTAssertNil(document.downloadCount)
        XCTAssertNil(document.size)
        XCTAssertEqual(document.typeIdentifier, kUTTypePNG as String)
    }

    func testInit_Document2Data() {
        let document = try! decoder.decode(DocumentResponse.self, from: DocumentResponseTests.document2Data)
        XCTAssertEqual(document.id, "F2")
        XCTAssertEqual(document.location, .external)
        XCTAssertEqual(document.externalUrl, URL(string: "https://www.apple.com/")!)
        XCTAssertNil(document.userId)
        XCTAssertEqual(document.name, "variante_B_04.png")
        XCTAssertEqual(document.createdAt.debugDescription, "2014-03-21 18:31:58 +0000")
        XCTAssertEqual(document.modifiedAt.debugDescription, "2014-03-21 18:31:58 +0000")
        XCTAssertNil(document.summary)
        XCTAssertNil(document.downloadCount)
        XCTAssertNil(document.size)
        XCTAssertEqual(document.typeIdentifier, kUTTypePNG as String)
    }

    // MARK: - Converting to Core Data Objects

    func testCoreDataObject_Document0() {
        let course0 = try! CourseResponse(id: "C0").coreDataObject(organization: organization, in: context)
        let folder0 = try! FolderResponse(id: "F3").coreDataObject(course: course0, in: context)
        let document = try! DocumentResponseTests.document0.coreDataObject(course: course0, parent: folder0, in: context)
        XCTAssertEqual(document.id, "F0")
        XCTAssertEqual(document.name, "file.pdf")
        XCTAssertEqual(document.typeIdentifier, kUTTypePDF as String)
        XCTAssertEqual(document.location, .invalid)
        XCTAssertNil(document.externalUrl)
        XCTAssertEqual(document.size, 1024)
        XCTAssertEqual(document.parent?.id, "F3")
        XCTAssertEqual(document.createdAt, Date(timeIntervalSince1970: 10))
        XCTAssertEqual(document.modifiedAt, Date(timeIntervalSince1970: 20))
        XCTAssertEqual(document.downloadCount, 42)
        XCTAssertEqual(document.summary, "Sümmary")
        XCTAssertEqual(document.owner?.id, "U0")
    }

    func testCoreDataObject_Document1() {
        let course0 = try! CourseResponse(id: "C0").coreDataObject(organization: organization, in: context)
        let folder0 = try! FolderResponse(id: "F3").coreDataObject(course: course0, in: context)
        let document = try! DocumentResponseTests.document1.coreDataObject(course: course0, parent: folder0, in: context)
        XCTAssertEqual(document.id, "F1")
        XCTAssertEqual(document.name, "image.png")
        XCTAssertEqual(document.typeIdentifier, kUTTypePNG as String)
        XCTAssertEqual(document.location, .invalid)
        XCTAssertNil(document.externalUrl)
        XCTAssertEqual(document.size, -1)
        XCTAssertEqual(document.parent?.id, "F3")
        XCTAssertEqual(document.createdAt, Date(timeIntervalSince1970: 1))
        XCTAssertEqual(document.modifiedAt, Date(timeIntervalSince1970: 2))
        XCTAssertEqual(document.downloadCount, -1)
        XCTAssertNil(document.summary)
        XCTAssertNil(document.owner)
    }

    func testCoreDataObject_Document2() {
        let course0 = try! CourseResponse(id: "C0").coreDataObject(organization: organization, in: context)
        let folder0 = try! FolderResponse(id: "F3").coreDataObject(course: course0, in: context)
        let document = try! DocumentResponseTests.document2.coreDataObject(course: course0, parent: folder0, in: context)
        XCTAssertEqual(document.id, "F2")
        XCTAssertEqual(document.name, "image.png")
        XCTAssertEqual(document.typeIdentifier, kUTTypePNG as String)
        XCTAssertEqual(document.location, .external)
        XCTAssertEqual(document.externalUrl, URL(string: "https://www.apple.com/")!)
        XCTAssertEqual(document.size, -1)
        XCTAssertEqual(document.parent?.id, "F3")
        XCTAssertEqual(document.createdAt, Date(timeIntervalSince1970: 1))
        XCTAssertEqual(document.modifiedAt, Date(timeIntervalSince1970: 2))
        XCTAssertEqual(document.downloadCount, -1)
        XCTAssertNil(document.summary)
        XCTAssertNil(document.owner)
    }
}
