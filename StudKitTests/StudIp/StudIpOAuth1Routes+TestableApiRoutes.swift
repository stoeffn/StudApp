//
//  StudIpOAuth1Routes+TestableApiRoutes.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 02.01.18.
//  Copyright © 2018 Steffen Ryll. All rights reserved.
//

@testable import StudKit

extension StudIpOAuth1Routes: TestableApiRoutes {
    func testData(for _: [URLQueryItem]) throws -> Data {
        throw NSError(domain: "", code: 0, userInfo: nil)
    }
}
