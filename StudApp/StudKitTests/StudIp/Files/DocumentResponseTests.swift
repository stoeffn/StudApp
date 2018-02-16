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

        _ = try! FolderResponse(id: "F1", courseId: "C0").coreDataObject(in: context)
        _ = try! FolderResponse(id: "F7", courseId: "C0").coreDataObject(in: context)

        _ = try! UserResponse(id: "U2").coreDataObject(in: context)
    }

    // MARK: - Coding

    func testInit_Document1Data() {
        let document = try! decoder.decode(DocumentResponse.self, from: DocumentResponseTests.document1Data)
        XCTAssertEqual(document.id, "3b06880ecf63d7e3ac4f45b1947a09d9")
        XCTAssertEqual(document.parentId, "e8471f3fde8c9c15a68e19e7691615d2")
        XCTAssertEqual(document.userId, "4e89bbf43f0e31ecc0ca81e09d572e27")
        XCTAssertEqual(document.name, "variante_B_04.png")
        XCTAssertEqual(document.createdAt.debugDescription, "2014-03-21 18:31:58 +0000")
        XCTAssertEqual(document.modifiedAt.debugDescription, "2014-03-21 18:31:58 +0000")
        XCTAssertEqual(document.summary, "Sümmary")
        XCTAssertEqual(document.downloadCount, 64)
        XCTAssertEqual(document.size, 1024)
        XCTAssertEqual(document.typeIdentifier, kUTTypePNG as String)
    }

    func testInit_Document2Data() {
        let document = try! decoder.decode(DocumentResponse.self, from: DocumentResponseTests.document2Data)
        XCTAssertEqual(document.id, "4b06880ecf63d7e3ac4f45b1947a09d9")
        XCTAssertEqual(document.parentId, "e8471f3fde8c9c15a68e19e7691615d2")
        XCTAssertEqual(document.userId, "4e89bbf43f0e31ecc0ca81e09d572e27")
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
        let file = try! DocumentResponseTests.document1.coreDataObject(in: context) as! File
        XCTAssertEqual(file.id, "F0")
        XCTAssertEqual(file.name, "file.pdf")
        XCTAssertEqual(file.typeIdentifier, kUTTypePDF as String)
        XCTAssertEqual(file.size, 1024)
        XCTAssertEqual(file.parent?.id, "F1")
        XCTAssertEqual(file.createdAt, Date(timeIntervalSince1970: 10))
        XCTAssertEqual(file.modifiedAt, Date(timeIntervalSince1970: 20))
        XCTAssertEqual(file.downloadCount, 42)
        XCTAssertEqual(file.summary, "Sümmary")
        XCTAssertEqual(file.owner?.id, "U2")
    }

    func testCoreDataObject_Document2() {
        let file = try! DocumentResponseTests.document2.coreDataObject(in: context) as! File
        XCTAssertEqual(file.id, "F8")
        XCTAssertEqual(file.name, "image.png")
        XCTAssertEqual(file.typeIdentifier, kUTTypePNG as String)
        XCTAssertEqual(file.size, -1)
        XCTAssertEqual(file.parent?.id, "F7")
        XCTAssertEqual(file.createdAt, Date(timeIntervalSince1970: 1))
        XCTAssertEqual(file.modifiedAt, Date(timeIntervalSince1970: 2))
        XCTAssertEqual(file.downloadCount, -1)
        XCTAssertNil(file.summary)
        XCTAssertNil(file.owner)
    }
}
