//
//  Result.swift
//  StudKit
//
//  Created by Steffen Ryll on 31.10.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

/// Completion handler that receives a result of the desired type or an error.
public typealias ResultCallback<Value> = (Result<Value>) -> Void

/// Container for either a value or an optional error.
///
/// Use this enumeration as a return or completion handler value instead of using a tuple consisting of both a value and an
/// error.
///
/// - success: Implies that the operation succeeded with a return value.
/// - failure: Implies that the operation failed with an optional error.
public enum Result<Value> {
    case failure(Error?)
    case success(Value)
    
    /// Creates a new operation result depending on whether the value given is `nil`.
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
        case .failure(let error): return error
        }
    }
    
    /// Returns the associated value if the result is a success, `nil` otherwise.
    public var value: Value? {
        switch self {
        case .success(let value): return value
        case .failure: return nil
        }
    }
    
    /// Returns a new operation result, keeping the error if set and replacing the value.
    ///
    /// - Remarks: This might be useful when transforming the result's data before returning it. The same rules as in
    ///            the initializer apply for `value` being `nil`.
    func replacingValue<NewValue>(_ value: NewValue?) -> Result<NewValue> {
        switch self {
        case .success:
            return Result<NewValue>(value)
        case .failure(let error):
            return .failure(error)
        }
    }
}
