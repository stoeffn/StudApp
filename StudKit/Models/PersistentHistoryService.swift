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

/// Manages Core Data Persistent History.
///
/// When using Core Data in multiple targets, e.g. an app as well as a file provider, it is crucial to merge changes from one
/// target into another because otherwise you would end up with inconsistent state. To that end, this Apple introduced
/// persistent history, which is a linear stream of changes that can be merged into the current context. This service takes
/// advantage of this feature by providing a simple interface for merging and deleting history. The latter is needed to free up
/// space after the history has been consumed by all targets. It uses history transactions' timestamps in order to determine
/// what to delete.
public final class PersistentHistoryService {
    /// Returns the latest persistent history transaction timestamp that is common to all targets given.
    private func lastCommonTransactionTimestamp(in targets: [Targets]) -> Date? {
        let timestamp = targets
            .map { $0.lastHistoryTransactionTimestamp ?? .distantPast }
            .min() ?? .distantPast
        return timestamp > .distantPast ? timestamp : nil
    }

    /// Delete persistent history that was successfully merged in _all_ of the targets provided. Call this method each time
    /// after merging persistent history.
    public func deleteHistory(mergedInto targets: [Targets], in context: NSManagedObjectContext) throws {
        guard #available(iOSApplicationExtension 11.0, *) else { return }

        guard let timestamp = lastCommonTransactionTimestamp(in: targets) else { return }
        let deleteHistoryRequest = NSPersistentHistoryChangeRequest.deleteHistory(before: timestamp)
        try context.execute(deleteHistoryRequest)
    }

    /// Merges persistent history into the context given and marks the current target as up-to-date. To delete history that was
    /// merged into every target, invoke `deleteHistory(mergedInto:in:)` after calling this method.
    ///
    /// - Parameter context: Managed object context, which should ideally be the view context or a context to be merged into the
    ///                      view context.
    /// - Postcondition: The current target's last history transaction timestamp is set to the last transaction timestamp.
    public func mergeHistory(into context: NSManagedObjectContext) throws {
        guard #available(iOSApplicationExtension 11.0, *), Distributions.current != .uiTest else { return }

        let historyFetchRequest = NSPersistentHistoryChangeRequest
            .fetchHistory(after: Targets.current.lastHistoryTransactionTimestamp ?? .distantPast)

        guard
            let historyResult = try context.execute(historyFetchRequest) as? NSPersistentHistoryResult,
            let history = historyResult.result as? [NSPersistentHistoryTransaction]
        else {
            fatalError("Cannot convert persistent history fetch result to transactions.")
        }

        for transaction in history {
            context.mergeChanges(fromContextDidSave: transaction.objectIDNotification())
        }

        if let lastTimestamp = history.last?.timestamp {
            var target = Targets.current
            target.lastHistoryTransactionTimestamp = lastTimestamp
        }
    }
}
