//
//  MockApi.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 27.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

@testable import StudKit

final class MockApi<Routes: TestableApiRoutes>: Api<Routes> {
    @discardableResult
    override func request(_ route: Routes, parameters: [URLQueryItem] = [], ignoreLastAccess _: Bool = false,
                          queue _: DispatchQueue = .main, handler: @escaping ResultHandler<Data>) -> URLSessionTask? {
        do {
            let data = try route.testData(for: parameters)
            handler(.success(data))
        } catch {
            handler(.failure(error))
        }
        return URLSessionTask()
    }
}
