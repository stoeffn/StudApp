//
//  ApiCredentialsTests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 24.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import XCTest
@testable import StudKit

final class ApiCredentialsTests: XCTestCase {
    func testAuthorizationValue_credentials_value() {
        let credentials = ApiCredentials(username: "demo", password: "password")
        XCTAssertEqual(credentials.authorizationValue, "Basic ZGVtbzpwYXNzd29yZA==")
    }
}
