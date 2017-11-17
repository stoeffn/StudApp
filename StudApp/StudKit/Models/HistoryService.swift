//
//  HistoryService.swift
//  StudKit
//
//  Created by Steffen Ryll on 17.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

public final class HistoryService {
    private var currentHistoryToken: NSPersistentHistoryToken?

    public func mergeHistory(into context: NSManagedObjectContext, handler: @escaping () -> Void) {
        context.performAndWait {
            let historyFetchRequest = NSPersistentHistoryChangeRequest.fetchHistory(after: currentHistoryToken)
            guard let historyResult = try? context.execute(historyFetchRequest) as? NSPersistentHistoryResult,
                let history = historyResult?.result as? [NSPersistentHistoryTransaction] else {
                    fatalError("Cannot fetch persistent history.")
            }

            for transaction in history {
                context.mergeChanges(fromContextDidSave: transaction.objectIDNotification())
                self.currentHistoryToken = transaction.token
            }

            handler()
        }
    }
}
