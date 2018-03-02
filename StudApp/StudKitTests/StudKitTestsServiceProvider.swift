//
//  StudKitTestsServiceProvider.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 28.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

@testable import StudKit

final class StudKitTestsServiceProvider: StudKitServiceProvider {
    override func provideReachabilityService() -> ReachabilityService {
        return ReachabilityService()
    }

    override func provideCoreDataService() -> CoreDataService {
        return CoreDataService(modelName: "StudKit", inMemory: true)
    }

    override func provideStudIpService() -> StudIpService {
        let api = MockApi<StudIpRoutes>(baseUrl: URL(string: "https://example.com")!)
        return StudIpService(api: api)
    }
}
