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

/// A simple condition that negates the evaluation of another condition.
///
/// This is useful (for example) if you want to only execute an operation if the network is NOT reachable.
struct NegatedCondition<Condition: OperationCondition>: OperationCondition {
    let condition: Condition

    // MARK: - Meta Data

    static var name: String {
        return "Not<\(Condition.name)>"
    }

    static var negatedConditionKey: String {
        return "NegatedCondition"
    }

    static var isMutuallyExclusive: Bool {
        return Condition.isMutuallyExclusive
    }

    // MARK: - Life Cycle

    init(condition: Condition) {
        self.condition = condition
    }

    // MARK: - Dependencies and Evaluation

    func dependency(for operation: BaseOperation) -> Operation? {
        return condition.dependency(for: operation)
    }

    func evaluate(for operation: BaseOperation, completion: @escaping (OperationConditionResults) -> Void) {
        condition.evaluate(for: operation) { result in
            if result == .satisfied {
                // If the composed condition succeeded, then this one failed.
                completion(.failed(NSError(code: .conditionFailed, userInfo: [
                    OperationConditionKey: type(of: self).name,
                    type(of: self).negatedConditionKey: type(of: self.condition).name,
                ])))
            } else {
                // If the composed condition failed, then this one succeeded.
                completion(.satisfied)
            }
        }
    }
}
