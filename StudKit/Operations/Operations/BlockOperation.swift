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

/// A closure type that takes a closure as its parameter.
typealias OperationBlock = (@escaping () -> Void) -> Void

/// A sublcass of `Operation` to execute a closure.
class BlockOperation: BaseOperation {
    private let block: OperationBlock?

    // MARK: - Life Cycle

    /// The designated initializer.
    ///
    /// - Parameter block: The closure to run when the operation executes. This closure will be run on an arbitrary queue. The
    ///                    parameter passed to the block **MUST** be invoked by your code, or else the `BlockOperation` will
    ///                    never finish executing. If this parameter is `nil`, the operation will immediately finish.
    init(block: OperationBlock? = nil) {
        self.block = block
        super.init()
    }

    /// A convenience initializer to execute a block on the main queue.
    ///
    /// - parameter mainQueueBlock: The block to execute on the main queue. Note that this block does not have a "continuation"
    ///                             block to execute (unlike the designated initializer). The operation will be automatically
    ///                             ended after the `mainQueueBlock` is executed.
    convenience init(mainQueueBlock: @escaping () -> Void) {
        self.init { continuation in
            DispatchQueue.main.async {
                mainQueueBlock()
                continuation()
            }
        }
    }

    // MARK: - Executing and Cancelling

    override func execute() {
        guard let block = block else { return finish() }
        block { self.finish() }
    }
}
