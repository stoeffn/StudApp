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

/// A condition that specifies that every dependency must have succeeded.
///
/// If any dependency was cancelled, the target operation will be cancelled as well.
struct NoCancelledDependencies: OperationCondition {

    // MARK: - Meta Data

    static let name = "NoCancelledDependencies"
    static let cancelledDependenciesKey = "CancelledDependencies"
    static let isMutuallyExclusive = false

    // MARK: - Life Cycle

    init() {}

    // MARK: - Dependencies and Evaluation

    func dependency(for _: BaseOperation) -> Operation? {
        return nil
    }

    func evaluate(for operation: BaseOperation, completion: (OperationConditionResults) -> Void) {
        // Verify that all of the dependencies executed.
        let cancelled = operation.dependencies.filter { $0.isCancelled }

        if !cancelled.isEmpty {
            // At least one dependency was cancelled; the condition was not satisfied.
            completion(.failed(NSError(code: .conditionFailed, userInfo: [
                OperationConditionKey: type(of: self).name,
                type(of: self).cancelledDependenciesKey: cancelled,
            ])))
        } else {
            completion(.satisfied)
        }
    }
}
