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

/// `TimeoutObserver` is a way to make an `Operation` automatically time out and cancel after a specified time interval.
struct TimeoutObserver: OperationObserving {
    static let timeoutKey = "Timeout"

    private let timeout: TimeInterval

    // MARK: - Life Cycle

    init(timeout: TimeInterval) {
        self.timeout = timeout
    }

    // MARK: Observing Operations

    func operationDidStart(_ operation: BaseOperation) {
        // When the operation starts, queue up a block to cause it to time out.
        DispatchQueue.global().asyncAfter(deadline: .now() + timeout) {
            // Cancel the operation if it hasn't finished and hasn't already been cancelled.
            guard !operation.isFinished && !operation.isCancelled else { return }

            operation.cancel(withError: NSError(code: .executionFailed, userInfo: [
                type(of: self).timeoutKey: self.timeout,
            ]))
        }
    }

    func operation(_: BaseOperation, didProduce _: Operation) {}

    func operationDidFinish(_: BaseOperation, errors _: [NSError]) {}
}
