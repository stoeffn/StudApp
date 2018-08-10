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

/// The subclass of `Operation` from which all other operations should be derived.
///
/// This class adds both Conditions and Observers, which allow the operation to define extended readiness requirements, as well
/// as notify many interested parties about interesting operation state changes
class BaseOperation: Operation {

    // MARK: - Configuring KVO

    @objc
    class func keyPathsForValuesAffectingIsReady() -> Set<String> {
        return [#keyPath(state)]
    }

    @objc
    class func keyPathsForValuesAffectingIsExecuting() -> Set<String> {
        return [#keyPath(state)]
    }

    @objc
    class func keyPathsForValuesAffectingIsFinished() -> Set<String> {
        return [#keyPath(state)]
    }

    // MARK: State Management

    @objc
    fileprivate enum States: Int, Comparable {
        /// The initial state of an `Operation`.
        case initialized

        /// The `Operation` is ready to begin evaluating conditions.
        case pending

        /// The `Operation` is evaluating conditions.
        case evaluatingConditions

        /// The `Operation`'s conditions have all been satisfied, and it is ready to execute.
        case ready

        /// The `Operation` is executing.
        case executing

        /// Execution of the `Operation` has finished, but it has not yet notified the queue of this.
        case finishing

        /// The `Operation` has finished executing.
        case finished

        // MARK: - Transitioning

        func canTransition(to state: States) -> Bool {
            switch (self, state) {
            case (.initialized, .pending),
                 (.pending, .evaluatingConditions),
                 (.evaluatingConditions, .ready),
                 (.ready, .executing),
                 (.ready, .finishing),
                 (.executing, .finishing),
                 (.finishing, .finished):
                return true
            default:
                return false
            }
        }

        // MARK: - Comparing Operation States

        static func < (lhs: BaseOperation.States, rhs: BaseOperation.States) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }

        static func == (lhs: BaseOperation.States, rhs: BaseOperation.States) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
    }

    /// Indicates that the Operation can now begin to evaluate readiness conditions, if appropriate.
    func willEnqueue() {
        state = .pending
    }

    // MARK: - Managing State

    /// Private storage for the `state` property that will be KVO observed.
    private var _state = States.initialized

    /// A lock to guard reads and writes to the `_state` property.
    private let stateLock = NSLock()

    @objc
    private var state: States {
        get {
            return stateLock.withCriticalScope { _state }
        }
        set {
            // It's important to note that the KVO notifications are NOT called from inside the lock. If they were, the app
            // would deadlock, because in the middle of calling the `didChangeValueForKey()` method, the observers try to access
            // properties like "isReady" or "isFinished". Since those methods also acquire the lock, then we'd be stuck waiting
            // on our own lock. It's the classic definition of deadlock.

            willChangeValue(for: \.state)

            stateLock.withCriticalScope {
                guard _state != .finished else { return }

                assert(_state.canTransition(to: newValue), "Performing invalid state transition.")
                _state = newValue
            }

            didChangeValue(for: \.state)
        }
    }

    // Here is where we extend our definition of "readiness".
    override var isReady: Bool {
        switch state {
        case .initialized:
            // If the operation has been cancelled, "isReady" should return true.
            return isCancelled
        case .pending:
            // If the operation has been cancelled, "isReady" should return true.
            guard !isCancelled else { return true }

            // If super isReady, conditions can be evaluated.
            if super.isReady {
                evaluateConditions()
            }

            // Until conditions have been evaluated, "isReady" returns false.
            return false
        case .ready:
            return super.isReady || isCancelled
        default:
            return false
        }
    }

    override var isExecuting: Bool { return state == .executing }

    override var isFinished: Bool { return state == .finished }

    var isUserInitiated: Bool {
        get { return qualityOfService == .userInitiated }
        set {
            assert(state < .executing, "Cannot modify userInitiated after execution has begun.")
            qualityOfService = newValue ? .userInitiated : .default
        }
    }

    private func evaluateConditions() {
        assert(state == .pending && !isCancelled, "evaluateConditions() was called out-of-order")

        state = .evaluatingConditions

        OperationConditionEvaluator.evaluate(conditions: conditions, operation: self) { failures in
            self._internalErrors.append(contentsOf: failures)
            self.state = .ready
        }
    }

    // MARK: - Managing Observers, Conditions, and Dependencies

    private(set) var conditions = [OperationCondition]()

    func add(condition: OperationCondition) {
        assert(state < .evaluatingConditions, "Cannot modify conditions after execution has begun.")

        conditions.append(condition)
    }

    private(set) var observers = [OperationObserving]()

    func add(observer: OperationObserving) {
        assert(state < .executing, "Cannot modify observers after execution has begun.")

        observers.append(observer)
    }

    override func addDependency(_ operation: Operation) {
        assert(state < .executing, "Dependencies cannot be modified after execution has begun.")

        super.addDependency(operation)
    }

    // MARK: - Executing and Cancelling

    final override func start() {
        // NSOperation.start() contains important logic that shouldn't be bypassed.
        super.start()

        // If the operation has been cancelled, we still need to enter the "Finished" state.
        if isCancelled {
            finish()
        }
    }

    final override func main() {
        assert(state == .ready, "This operation must be performed on an operation queue.")

        if _internalErrors.isEmpty && !isCancelled {
            state = .executing
            observers.forEach { $0.operationDidStart(self) }
            execute()
        } else {
            finish()
        }
    }

    /// `execute()` is the entry point of execution for all `Operation` subclasses.
    ///
    /// If you subclass `Operation` and wish to customize its execution, you would do so by overriding the `execute()` method.
    ///
    /// At some point, your `Operation` subclass must call one of the "finish" methods defined below; this is how you indicate
    /// that your operation has finished its execution, and that operations dependent on yours can re-evaluate their readiness
    /// state.
    func execute() {
        print("\(type(of: self)) must override `execute()`.")
        finish()
    }

    private var _internalErrors = [NSError]()

    func cancel(withError error: NSError? = nil) {
        if let error = error {
            _internalErrors.append(error)
        }
        cancel()
    }

    final func produce(operation: Operation) {
        observers.forEach { $0.operation(self, didProduce: operation) }
    }

    // MARK: - Finishing

    /// Most operations may finish with a single error, if they have one at all. This is a convenience method to simplify
    /// calling the actual `finish()` method. This is also useful if you wish to finish with an error provided by the system
    /// frameworks. As an example, see `DownloadEarthquakesOperation` for how an error from an `URLSession` is passed along via
    /// the `finishWithError()` method.
    final func finish(withError error: NSError?) {
        finish(withErrors: [error].compactMap { $0 })
    }

    /// A private property to ensure we only notify the observers once that the operation has finished.
    private var hasFinishedAlready = false

    final func finish(withErrors errors: [NSError] = []) {
        guard !hasFinishedAlready else { return }

        hasFinishedAlready = true
        state = .finishing

        let combinedErrors = _internalErrors + errors
        finished(errors: combinedErrors)

        for observer in observers {
            observer.operationDidFinish(self, errors: combinedErrors)
        }

        state = .finished
    }

    /// Subclasses may override `finished(_:)` if they wish to react to the operation finishing with errors. For example, the
    /// `LoadModelOperation` implements this method to potentially inform the user about an error when trying to bring up the
    /// Core Data stack.
    func finished(errors _: [NSError]) {}

    /// Crashes your app.
    ///
    /// Waiting on operations is almost NEVER the right thing to do. It is usually superior to use proper locking constructs,
    /// such as `DispatchSemaphore` or `DispatchGroup.notify`, or even `NSLocking` objects. Many developers use waiting when
    /// they should instead be chaining discrete operations together using dependencies.
    ///
    /// To reinforce this idea, invoking `waitUntilFinished()` will crash your app, as incentive for you to find a more
    /// appropriate way to express the behavior you're wishing to create.
    final override func waitUntilFinished() {
        fatalError("Waiting on operations is an anti-pattern. Remove this ONLY if you're absolutely sure there is No Other Way™.")
    }
}
