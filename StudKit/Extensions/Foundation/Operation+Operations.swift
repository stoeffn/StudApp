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

extension Operation {
    /// Add a completion block to be executed after the `NSOperation` enters the "finished" state.
    func addCompletionBlock(block: @escaping () -> Void) {
        if let existing = completionBlock {
            // If we already have a completion block, we construct a new one by chaining them together.
            completionBlock = {
                existing()
                block()
            }
        } else {
            completionBlock = block
        }
    }

    /// Add multiple depdendencies to the operation.
    func addDependencies(dependencies: [Operation]) {
        for dependency in dependencies {
            addDependency(dependency)
        }
    }
}
