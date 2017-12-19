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

    func testInit_AnnouncmentData_Annoucnment() {
        let announcement = try! decoder.decode(AnnouncementResponse.self, from: AnnouncementResponseTests.announcementData)
        XCTAssertEqual(announcement.id, "d8b6b4df0950483bc1911adfff93737b")
        XCTAssertEqual(announcement.createdAt!.debugDescription, "2017-12-12 11:48:42 +0000")
        XCTAssertEqual(announcement.modifiedAt!.debugDescription, "2017-12-12 11:48:42 +0000")
        XCTAssertEqual(announcement.expiresAt!.debugDescription, "2018-01-09 11:47:42 +0000")
        XCTAssertEqual(announcement.title, "Weihnachtspause")
        XCTAssertEqual(announcement.body, "Liebe Studierende,\r\n\r\ndies ist ein Test.")
    }
}
