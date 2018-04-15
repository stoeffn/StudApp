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

/// Closure, usually a completion handler, that receives a result of the desired type or an error.
public typealias ResultHandler<Value> = (Result<Value>) -> Void

/// Container for either a value or an optional error.
///
/// Use this enumeration as a return or completion handler value instead of using a tuple consisting of both a value and an
/// error.
///
/// - success: Implies that an operation succeeded with a return value.
/// - failure: Implies that an operation failed with an optional error.
public enum Result<Value> {
    case failure(Error?)
    case success(Value)

    /// Creates a new result depending on whether the value given is `nil`.
    ///
    /// - Parameters:
    ///   - value: Optional value. Result will be a failure if set to `nil`.
    ///   - error: Optional error. Result will be a failure if set.
    init(_ value: Value?, error: Error? = nil) {
        if let value = value, error == nil {
            self = .success(value)
            return
        }
        self = .failure(error)
    }

    /// Returns whether self is `success`.
    public var isSuccess: Bool {
        switch self {
        case .success: return true
        case .failure: return false
        }
    }

    /// Returns `true` if the result is a failure, `false` otherwise.
    public var isFailure: Bool {
        return !isSuccess
    }

    /// Returns the associated error if attached, `nil` otherwise.
    public var error: Error? {
        switch self {
        case .success: return nil
        case let .failure(error): return error
        }
    }

    /// Returns the associated value if the result is a success, `nil` otherwise.
    public var value: Value? {
        switch self {
        case let .success(value): return value
        case .failure: return nil
        }
    }

    /// Applies a transform to a result value if it is a `success`.
    ///
    /// - Parameter transform: Transform to apply to `value`.
    /// - Returns: `.failure` if this result is a failure or `transform` throws. Otherwise, a result with the transformed value
    ///            is returned.
    func map<NewValue>(_ transform: (Value) throws -> NewValue) -> Result<NewValue> {
        switch self {
        case let .success(value):
            do {
                return .success(try transform(value))
            } catch {
                return .failure(error)
            }
        case let .failure(error):
            return .failure(error)
        }
    }

    /// Applies a transform to a result value if it is a `success`.
    ///
    /// - Parameter transform: Transform to apply to `value`.
    /// - Returns: `.failure` if this result is a failure, `transform` throws, or `transform` returns `nil`. Otherwise, a result
    ///            with the transformed value is returned.
    func compactMap<NewValue>(_ transform: (Value) throws -> NewValue?) -> Result<NewValue> {
        switch self {
        case let .success(value):
            do {
                return Result<NewValue>(try transform(value))
            } catch {
                return .failure(error)
            }
        case let .failure(error):
            return .failure(error)
        }
    }
}
