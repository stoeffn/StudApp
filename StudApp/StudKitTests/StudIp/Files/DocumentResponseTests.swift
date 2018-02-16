//
//  DocumentResponseTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 16.02.18.
//  Copyright © 2018 Steffen Ryll. All rights reserved.
//

import MobileCoreServices
import XCTest
@testable import StudKit

final class DocumentResponseTests: XCTestCase {
    let decoder = ServiceContainer.default[JSONDecoder.self]

    func testInit_DocumentData_Document() {
        let document = try! decoder.decode(DocumentResponse.self, from: DocumentResponseTests.documentData)
        XCTAssertEqual(document.id, "3b06880ecf63d7e3ac4f45b1947a09d9")
        XCTAssertEqual(document.parentId, "e8471f3fde8c9c15a68e19e7691615d2")
        XCTAssertEqual(document.userId, "4e89bbf43f0e31ecc0ca81e09d572e27")
        XCTAssertEqual(document.name, "variante_B_04.png")
        XCTAssertEqual(document.createdAt.debugDescription, "2014-03-21 18:31:58 +0000")
        XCTAssertEqual(document.modifiedAt.debugDescription, "2014-03-21 18:31:58 +0000")
        XCTAssertEqual(document.summary, "Sümmary")
        XCTAssertEqual(document.downloadCount, 64)
        XCTAssertEqual(document.typeIdentifier, kUTTypePNG as String)
    }
}
