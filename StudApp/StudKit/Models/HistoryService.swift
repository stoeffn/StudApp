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
    private var currentHistoryToken: NSPersistentHistoryToken?

    public init(currentTarget: Targets) {
        self.currentTarget = currentTarget
    }

    public func isHistoryTransaction(withToken token: NSPersistentHistoryToken, mergedInto targets: [Targets]) -> Bool {
        return true
    }

    public func mergeHistory(into context: NSManagedObjectContext) {
        let historyFetchRequest = NSPersistentHistoryChangeRequest.fetchHistory(after: currentHistoryToken)
        guard let historyResult = try? context.execute(historyFetchRequest) as? NSPersistentHistoryResult,
            let history = historyResult?.result as? [NSPersistentHistoryTransaction] else {
                fatalError("Cannot fetch persistent history.")
        }

        for transaction in history {
            context.mergeChanges(fromContextDidSave: transaction.objectIDNotification())
        }

        currentHistoryToken = history.last?.token ?? currentHistoryToken
    }
}
