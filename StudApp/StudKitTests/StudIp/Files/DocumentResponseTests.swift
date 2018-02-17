//
//  DocumentResponseTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 16.02.18.
//  Copyright © 2018 Steffen Ryll. All rights reserved.
//

import CoreData
import MobileCoreServices
import XCTest
@testable import StudKit

final class DocumentResponseTests: XCTestCase {
    let decoder = ServiceContainer.default[JSONDecoder.self]
    var context: NSManagedObjectContext!

    // MARK: - Life Cycle

    override func setUp() {
        context = StudKitTestsServiceProvider(currentTarget: .tests).provideCoreDataService().viewContext

        try! UserResponse(id: "U0").coreDataObject(in: context)
    }

    // MARK: - Coding

    func testInit_Document0Data() {
        let document = try! decoder.decode(DocumentResponse.self, from: DocumentResponseTests.document0Data)
        XCTAssertEqual(document.id, "F0")
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

    func testCoreDataObject_Document1() {
        let course0 = try! CourseResponse(id: "C0").coreDataObject(in: context)
        let folder0 = try! FolderResponse(id: "F2").coreDataObject(course: course0, in: context)
        let document = try! DocumentResponseTests.document0.coreDataObject(course: course0, parent: folder0, in: context)
        XCTAssertEqual(document.id, "F0")
        XCTAssertEqual(document.name, "file.pdf")
        XCTAssertEqual(document.typeIdentifier, kUTTypePDF as String)
        XCTAssertEqual(document.size, 1024)
        XCTAssertEqual(document.parent?.id, "F2")
        XCTAssertEqual(document.createdAt, Date(timeIntervalSince1970: 10))
        XCTAssertEqual(document.modifiedAt, Date(timeIntervalSince1970: 20))
        XCTAssertEqual(document.downloadCount, 42)
        XCTAssertEqual(document.summary, "Sümmary")
        XCTAssertEqual(document.owner?.id, "U0")
    }

    func testCoreDataObject_Document2() {
        let course0 = try! CourseResponse(id: "C0").coreDataObject(in: context)
        let folder0 = try! FolderResponse(id: "F2").coreDataObject(course: course0, in: context)
        let document = try! DocumentResponseTests.document1.coreDataObject(course: course0, parent: folder0, in: context)
        XCTAssertEqual(document.id, "F1")
        XCTAssertEqual(document.name, "image.png")
        XCTAssertEqual(document.typeIdentifier, kUTTypePNG as String)
        XCTAssertEqual(document.size, -1)
        XCTAssertEqual(document.parent?.id, "F2")
        XCTAssertEqual(document.createdAt, Date(timeIntervalSince1970: 1))
        XCTAssertEqual(document.modifiedAt, Date(timeIntervalSince1970: 2))
        XCTAssertEqual(document.downloadCount, -1)
        XCTAssertNil(document.summary)
        XCTAssertNil(document.owner)
    }
}
