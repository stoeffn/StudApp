//
//  TestableApiRoutes.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 27.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

@testable import StudKit

protocol TestableApiRoutes : ApiRoutes {
    func testData(for parameters: [URLQueryItem]) throws -> Data
}
