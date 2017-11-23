//
//  HistoryService.swift
//  StudKit
//
//  Created by Steffen Ryll on 17.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

/// Manages Core Data persistent history.
///
/// When using Core Data in multiple targets, e.g. an app as well as a file provider, it is crucial to merge changes from one
/// target into another because otherwise you would end up with inconsistent state. To that end, this Apple introduced
/// persistent history, which is a linear stream of changes that can be merged into the current context. This service takes
/// advantage of this feature by providing a simple interface for merging and deleting history. The latter is needed to free up
/// space after the history has been consumed by all targets. It uses history transactions' timestamps in order to determine
/// what to delete.
public final class HistoryService {
    /// Current target, whose last transaction timestamp is used and modified.
    private var currentTarget: Targets

    public init(currentTarget: Targets) {
        self.currentTarget = currentTarget
    }

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
        guard let timestamp = lastCommonTransactionTimestamp(in: targets) else { return }
        let deleteHistoryRequest = NSPersistentHistoryChangeRequest.deleteHistory(before: timestamp)
        try context.execute(deleteHistoryRequest)
    }

    /// Merges persistent history into the context given and marks the current target as up-to-date. To delete history that was
    /// merged into every target, invoke `deleteHistory(mergedInto:in:)` after calling this method.
    ///
    /// - Postcondition: The current target's last history transaction timestamp is set to the last transaction timestamp.
    public func mergeHistory(into context: NSManagedObjectContext) throws {
        let historyFetchRequest = NSPersistentHistoryChangeRequest
            .fetchHistory(after: currentTarget.lastHistoryTransactionTimestamp ?? .distantPast)
        guard let historyResult = try context.execute(historyFetchRequest) as? NSPersistentHistoryResult,
            let history = historyResult.result as? [NSPersistentHistoryTransaction] else {
            fatalError("Cannot convert persistent history fetch result to transaction.")
        }

        for transaction in history {
            context.mergeChanges(fromContextDidSave: transaction.objectIDNotification())
        }

        if let lastTimestamp = history.last?.timestamp {
            currentTarget.lastHistoryTransactionTimestamp = lastTimestamp
        }
    }
}
