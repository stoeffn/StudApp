//
//  StudAppUITests.swift
//  StudAppUITests
//
//  Created by Steffen Ryll on 31.10.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import XCTest

final class StudAppUITests: XCTestCase {
    public let uiTestsProcessArgument = "uiTest"

    // MARK: - Life Cycle

    override func setUp() {
        super.setUp()

        continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments = [uiTestsProcessArgument]
        app.launch()
    }
}
