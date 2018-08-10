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

/// `ExclusivityController` is a singleton to keep track of all the in-flight `Operation` instances that have declared
/// themselves as requiring mutual exclusivity.
///
/// We use a singleton because mutual exclusivity must be enforced across the entire app, regardless of the `OperationQueue` on
/// which an `Operation` was executed.
class ExclusivityController {
    static let sharedExclusivityController = ExclusivityController()

    private let serialQueue = DispatchQueue(label: "Operations.ExclusivityController")
    private var operations: [String: [Operation]] = [:]

    // MARK: - Life Cycle

    private init() {}

    // MARK: - Managing Operations

    /// Registers an operation as being mutually exclusive
    func add(operation: Operation, categories: [String]) {
        // This needs to be a synchronous operation. If this were async, then we might not get around to adding dependencies
        // until after the operation had already begun, which would be incorrect.
        serialQueue.sync {
            categories.forEach { self.unsafelyAdd(operation: operation, category: $0) }
        }
    }

    /// Unregisters an operation from being mutually exclusive.
    func remove(operation: Operation, categories: [String]) {
        serialQueue.async {
            categories.forEach { self.unsafelyRemove(operation: operation, category: $0) }
        }
    }

    private func unsafelyAdd(operation: Operation, category: String) {
        var operationsWithThisCategory = operations[category] ?? []

        if let last = operationsWithThisCategory.last {
            operation.addDependency(last)
        }

        operationsWithThisCategory.append(operation)
        operations[category] = operationsWithThisCategory
    }

    private func unsafelyRemove(operation: Operation, category: String) {
        guard
            var operationsWithThisCategory = operations[category],
            let index = operationsWithThisCategory.index(of: operation)
        else { return }

        operationsWithThisCategory.remove(at: index)
        operations[category] = operationsWithThisCategory
    }
}
