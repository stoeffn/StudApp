//
//  HistoryService.swift
//  StudKit
//
//  Created by Steffen Ryll on 17.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

public final class HistoryService {
    private var currentTarget: Targets
    private var lastTransactionTimestamp: Date?

    public init(currentTarget: Targets) {
        self.currentTarget = currentTarget

        lastTransactionTimestamp = currentTarget.lastHistoryTransactionTimestamp
    }

    func lastCommonTransactionTimestamp(in targets: [Targets]) -> Date? {
        return targets
            .map { $0.lastHistoryTransactionTimestamp ?? .distantPast }
            .min()
    }

    public func deleteHistory(mergedInto targets: [Targets], in context: NSManagedObjectContext) throws {
        guard let timestamp = lastCommonTransactionTimestamp(in: targets) else { return }
        let deleteHistoryRequest = NSPersistentHistoryChangeRequest.deleteHistory(before: timestamp)
        try context.execute(deleteHistoryRequest)
    }

    public func mergeHistory(into context: NSManagedObjectContext) throws {
        let historyFetchRequest = NSPersistentHistoryChangeRequest.fetchHistory(after: lastTransactionTimestamp ?? .distantPast)
        guard let historyResult = try context.execute(historyFetchRequest) as? NSPersistentHistoryResult,
            let history = historyResult.result as? [NSPersistentHistoryTransaction] else {
            fatalError("Cannot convert persistent history fetch result to transaction.")
        }

        for transaction in history {
            context.mergeChanges(fromContextDidSave: transaction.objectIDNotification())
        }

        lastTransactionTimestamp = history.last?.timestamp ?? lastTransactionTimestamp
        currentTarget.lastHistoryTransactionTimestamp = lastTransactionTimestamp
    }
}
