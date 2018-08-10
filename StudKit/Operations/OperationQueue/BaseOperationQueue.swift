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

/// The delegate of an `BaseOperationQueue` can respond to `BaseOperation` lifecycle events by implementing these methods.
///
/// In general, implementing `OperationQueueDelegate` is not necessary; you would want to use an `OperationObserver` instead.
/// However, there are a couple of situations where using `OperationQueueDelegate` can lead to simpler code. For example,
/// `GroupOperation` is the delegate of its own internal `OperationQueue` and uses it to manage dependencies.
@objc
protocol BaseOperationQueueDelegate: NSObjectProtocol {
    @objc
    optional func operationQueue(_ queue: BaseOperationQueue, willAdd operation: Operation)

    @objc
    optional func operationQueue(_ queue: BaseOperationQueue, didFinish operation: Operation, errors: [NSError])
}

/// `BaseOperationQueue` is an `OperationQueue` subclass that implements a large number of "extra features" related to the
/// `BaseOperation` class.
///
/// - Notifying a delegate of all operation completion
/// - Extracting generated dependencies from operation conditions
/// - Setting up dependencies to enforce mutual exclusivity
class BaseOperationQueue: OperationQueue {
    weak var delegate: BaseOperationQueueDelegate?

    override func addOperation(_ operation: Operation) {
        if let operation = operation as? BaseOperation {
            // Set up a `BlockObserver` to invoke the `OperationQueueDelegate` method.
            operation.add(observer: BlockObserver(
                startHandler: nil,
                produceHandler: { [weak self] in self?.addOperation($1) },
                finishHandler: { [weak self] in
                    if let queue = self {
                        queue.delegate?.operationQueue?(queue, didFinish: $0, errors: $1)
                    }
            }))

            // Extract any dependencies needed by this operation.
            let dependencies = operation.conditions.compactMap { $0.dependency(for: operation) }

            for dependency in dependencies {
                operation.addDependency(dependency)
                addOperation(dependency)
            }

            // With condition dependencies added, we can now see if this needs dependencies to enforce mutual exclusivity.
            let concurrencyCategories: [String] = operation.conditions.compactMap { condition in
                guard type(of: condition).isMutuallyExclusive else { return nil }
                return String(describing: type(of: condition))
            }

            if !concurrencyCategories.isEmpty {
                ExclusivityController.sharedExclusivityController.add(operation: operation, categories: concurrencyCategories)
                operation.add(observer: BlockObserver { operation, _ in
                    ExclusivityController.sharedExclusivityController.remove(operation: operation, categories: concurrencyCategories)
                })
            }

            // Indicate to the operation that we've finished our extra work on it and it's now it a state where it can proceed
            // with evaluating conditions, if appropriate.
            operation.willEnqueue()
        } else {
            // For regular `Operation`s, we'll manually call out to the queue's delegate we don't want to just capture
            // "operation" because that would lead to the operation strongly referencing itself and that's the pure definition
            // of a memory leak.
            operation.addCompletionBlock { [weak self, weak operation] in
                guard let queue = self, let operation = operation else { return }
                queue.delegate?.operationQueue?(queue, didFinish: operation, errors: [])
            }
        }

        delegate?.operationQueue?(self, willAdd: operation)
        super.addOperation(operation)
    }

    override func addOperations(_ operations: [Operation], waitUntilFinished wait: Bool) {
        // The base implementation of this method does not call `addOperation()`, so we'll call it ourselves.
        operations.forEach(addOperation)

        guard wait else { return }
        operations.forEach { $0.waitUntilFinished() }
    }
}
