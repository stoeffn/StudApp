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

/// A subclass of `Operation` that executes zero or more operations as part of its own execution.
///
/// This class of operation is very useful for abstracting several smaller operations into a larger operation. As an example,
/// the `GetEarthquakesOperation` is composed of both a `DownloadEarthquakesOperation` and a `ParseEarthquakesOperation`.
///
/// Additionally, `GroupOperation`s are useful if you establish a chain of dependencies, but part of the chain may "loop". For
/// example, if you have an operation that requires the user to be authenticated, you may consider putting the "login" operation
/// inside a group operation. That way, the "login" operation may produce subsequent operations (still within the outer
/// `GroupOperation`) that will all be executed before the rest of the operations in the initial chain of operations.
class GroupOperation: BaseOperation {
    private let internalQueue = BaseOperationQueue()
    private let startingOperation = BlockOperation()
    private let finishingOperation = BlockOperation()

    private var aggregatedErrors = [NSError]()

    // MARK: - Life Cycle

    init(operations: [Operation]) {
        super.init()

        internalQueue.isSuspended = true
        internalQueue.delegate = self
        internalQueue.addOperation(startingOperation)
        operations.forEach(internalQueue.addOperation)
    }

    convenience init(operations: Operation...) {
        self.init(operations: operations)
    }

    // MARK: - Executing and Cancelling

    override func execute() {
        internalQueue.isSuspended = false
        internalQueue.addOperation(finishingOperation)
    }

    override func cancel() {
        internalQueue.cancelAllOperations()
        super.cancel()
    }

    // MARK: - Managing Sub-Operations

    func addOperation(operation: Operation) {
        internalQueue.addOperation(operation)
    }

    /// Note that some part of execution has produced an error. Errors aggregated through this method will be included in the
    /// final array of errors reported to observers and to the `finished(_:)` method.
    final func aggregateError(error: NSError) {
        aggregatedErrors.append(error)
    }

    // MARK: - Finishing

    func operationDidFinish(operation _: Operation, withErrors _: [NSError]) {}
}

// MARK: - Observing Sub-Operations

extension GroupOperation: BaseOperationQueueDelegate {
    final func operationQueue(_: BaseOperationQueue, willAdd operation: Operation) {
        assert(!finishingOperation.isFinished && !finishingOperation.isExecuting,
               "cannot add new operations to a group after the group has completed")

        // Some operation in this group has produced a new operation to execute. We want to allow that operation to execute
        // before the group completes, so we'll make the finishing operation dependent on this newly-produced operation.
        if operation !== finishingOperation {
            finishingOperation.addDependency(operation)
        }

        // All operations should be dependent on the "startingOperation". This way, we can guarantee that the conditions for
        // other operations will not evaluate until just before the operation is about to run. Otherwise, the conditions could
        // be evaluated at any time, even  before the internal operation queue is unsuspended.
        if operation !== startingOperation {
            operation.addDependency(startingOperation)
        }
    }

    final func operationQueue(_: BaseOperationQueue, operationDidFinish operation: Operation, errors: [NSError]) {
        aggregatedErrors.append(contentsOf: errors)

        if operation === finishingOperation {
            internalQueue.isSuspended = true
            finish(withErrors: aggregatedErrors)
        } else if operation !== startingOperation {
            operationDidFinish(operation: operation, withErrors: errors)
        }
    }
}
