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

/// A generic condition for describing kinds of operations that may not execute concurrently.
struct MutuallyExclusive<T>: OperationCondition {

    // MARK: - Meta Data

    static var name: String {
        return "MutuallyExclusive<\(T.self)>"
    }

    static var isMutuallyExclusive: Bool {
        return true
    }

    // MARK: - Life Cycle

    init() {}

    // MARK: - Dependencies and Evaluation

    func dependency(for _: BaseOperation) -> Operation? {
        return nil
    }

    func evaluate(for _: BaseOperation, completion: (OperationConditionResults) -> Void) {
        completion(.satisfied)
    }
}

// MARK: - Alerts

/// The purpose of this enum is to simply provide a non-constructible type to be used with `MutuallyExclusive<T>`.
enum Alert {}

/// A condition describing that the targeted operation may present an alert.
typealias AlertPresentation = MutuallyExclusive<Alert>
