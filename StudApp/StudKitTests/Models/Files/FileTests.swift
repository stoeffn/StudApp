//
//  FileTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 24.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import XCTest
@testable import StudKit

final class FileTests: XCTestCase {
    private let decoder = ServiceContainer.default[JSONDecoder.self]
    private var context: NSManagedObjectContext!

    // MARK: - Life Cycle

    override func setUp() {
        context = StudKitTestsServiceProvider(currentTarget: .tests).provideCoreDataService().viewContext
    }
}
