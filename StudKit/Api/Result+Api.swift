//
//  StudApp—Stud.IP to Go
//  Copyright © 2018, Steffen Ryll
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see http://www.gnu.org/licenses/.
//

extension Result {
    /// Creates a new result depending on whether the value given is `nil`.
    ///
    /// - Parameters:
    ///   - value: Optional value. Result will be a failure if set to `nil`.
    ///   - error: Optional error. Result will be a failure if set.
    ///   - statusCode: Optional HTTP status code. Result will be a failure if not in the 200 range.
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
        let decoder = ServiceContainer.default[JSONDecoder.self]
        return map { try decoder.decode(type, from: $0) }
    }
}
