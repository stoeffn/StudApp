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

/// A simple condition that causes another condition to not enqueue its dependency.
///
/// This is useful (for example) when you want to verify that you have access to the user's location, but you do not want to
/// prompt them for permission if you do not already have it.
struct SilentCondition<T: OperationCondition>: OperationCondition {
    let condition: T

    // MARK: - Meta Data

    static var name: String {
        return "Silent<\(T.name)>"
    }

    static var isMutuallyExclusive: Bool {
        return T.isMutuallyExclusive
    }

    // MARK: - Life Cycle

    init(condition: T) {
        self.condition = condition
    }

    // MARK: - Dependencies and Evaluation

    func dependency(for _: BaseOperation) -> Operation? {
        // Returning nil means we will never a dependency to be generated.
        return nil
    }

    func evaluate(for operation: BaseOperation, completion: @escaping (OperationConditionResults) -> Void) {
        condition.evaluate(for: operation, completion: completion)
    }
}
