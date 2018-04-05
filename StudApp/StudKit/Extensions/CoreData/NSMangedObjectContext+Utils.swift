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

import CoreData

public extension NSManagedObjectContext {
    /// Attempts to commit unsaved changes to registered objects to the context’s parent store on the context's queue if there
    /// are unsaved changes.
    ///
    /// If a context’s parent store is a persistent store coordinator, then changes are committed to the external store. If a
    /// context’s parent store is another managed object context, then `save()` only updates managed objects in that parent
    /// store. To commit changes to the external store, you must save changes in the chain of contexts up to and including the
    /// context whose parent is the persistent store coordinator.
    func saveAndWaitWhenChanged() throws {
        guard hasChanges else { return }

        var saveError: Error?

        performAndWait {
            do {
                try self.save()
            } catch {
                saveError = error
            }
        }

        if let error = saveError {
            throw error
        }
    }
}
