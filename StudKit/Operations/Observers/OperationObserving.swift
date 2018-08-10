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

/// The protocol that types may implement if they wish to be notified of significant operation lifecycle events.
protocol OperationObserving {
    /// Invoked immediately prior to the `BaseOperation`'s `execute()` method.
    func operationDidStart(_ operation: BaseOperation)

    /// Invoked when `BaseOperation.produceOperation(_:)` is executed.
    func operation(_ operation: BaseOperation, didProduce newOperation: Operation)

    /// Invoked as an `BaseOperation` finishes, along with any errors produced during execution (or readiness evaluation).
    func operationDidFinish(_ operation: BaseOperation, errors: [NSError])
}
