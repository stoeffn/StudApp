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

let OperationConditionKey = "OperationCondition"

/// A protocol for defining conditions that must be satisfied in order for an operation to begin execution.
protocol OperationCondition {

    // MARK: Meta Data

    /// The name of the condition. This is used in userInfo dictionaries of `.conditionFailed` errors as the value of the
    /// `OperationConditionKey` key.
    static var name: String { get }

    /// Specifies whether multiple instances of the conditionalized operation may be executing simultaneously.
    static var isMutuallyExclusive: Bool { get }

    // MARK: Dependencies and Evaluation

    /// Some conditions may have the ability to satisfy the condition if another operation is executed first. Use this method to
    /// return an operation that (for example) asks for permission to perform the operation.
    ///
    /// - parameter operation: The `Operation` to which the Condition has been added.
    /// - returns: An `Operation`, if a dependency should be automatically added. Otherwise, `nil`.
    /// - note: Only a single operation may be returned as a dependency. If you find that you need to return multiple
    ///         operations, then you should be expressing that as multiple conditions. Alternatively, you could return a single
    ///         `GroupOperation` that executes multiple operations internally.
    func dependency(for operation: BaseOperation) -> Operation?

    /// Evaluate the condition, to see if it has been satisfied or not.
    func evaluate(for operation: BaseOperation, completion: @escaping (OperationConditionResults) -> Void)
}

// MARK: - Results

/// An enum to indicate whether an `OperationCondition` was satisfied, or if it failed with an error.
enum OperationConditionResults: Equatable {
    case satisfied
    case failed(NSError)

    var error: NSError? {
        switch self {
        case let .failed(error):
            return error
        default:
            return nil
        }
    }

    static func == (lhs: OperationConditionResults, rhs: OperationConditionResults) -> Bool {
        switch (lhs, rhs) {
        case (.satisfied, .satisfied):
            return true
        case let (.failed(lError), .failed(rError)) where lError == rError:
            return true
        default:
            return false
        }
    }
}

// MARK: - Evaluating Conditions

struct OperationConditionEvaluator {
    static func evaluate(conditions: [OperationCondition], operation: BaseOperation, completion: @escaping ([NSError]) -> Void) {
        let conditionGroup = DispatchGroup()
        var results = [OperationConditionResults?](repeating: nil, count: conditions.count)

        // Ask each condition to evaluate and store its result in the "results" array.
        for (index, condition) in conditions.enumerated() {
            conditionGroup.enter()
            condition.evaluate(for: operation) { result in
                results[index] = result
                conditionGroup.leave()
            }
        }

        // After all the conditions have evaluated, this block will execute.
        conditionGroup.notify(queue: .main) {
            // Aggregate the errors that occurred, in order.
            var failures = results.compactMap { $0?.error }

            // If any of the conditions caused this operation to be cancelled, check for that.
            if operation.isCancelled {
                failures.append(NSError(code: .conditionFailed))
            }

            completion(failures)
        }
    }
}
