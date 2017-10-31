//
//  MockApi.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 27.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

@testable import StudKit

final class MockApi<Routes : TestableApiRoutes> : Api<Routes> {
    @discardableResult
    override func request(_ route: Routes, parameters: [URLQueryItem] = [], completionHandler: @escaping ResultCallback<Data>) -> Progress {
        do {
            let data = try route.testData(for: parameters)
            completionHandler(.success(data))
        } catch {
            completionHandler(.failure(error))
        }
        return Progress()
    }
}
