//
//  Result+Api.swift
//  StudKit
//
//  Created by Steffen Ryll on 24.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

extension Result {
    init(_ value: Value?, error: Error? = nil, statusCode: Int?) {
        if let value = value, let statusCode = statusCode, error == nil, 200 ... 299 ~= statusCode {
            self = .success(value)
            return
        }
        self = .failure(error)
    }
}

// MARK: - Default Implementation

extension Result where Value == Data {
    /// Returns the API result decoded from its JSON representation. If the data is not valid, the return value will be a
    /// `.failure`.
    ///
    /// - Parameter type: Expected object type.
    func decoded<Value: Decodable>(_ type: Value.Type) -> Result<Value> {
        guard case let .success(value) = self else {
            return replacingValue(nil)
        }
        do {
            let decoder = ServiceContainer.default[JSONDecoder.self]
            let value = try decoder.decode(type, from: value)
            return replacingValue(value)
        } catch {
            return replacingValue(nil)
        }
    }
}
