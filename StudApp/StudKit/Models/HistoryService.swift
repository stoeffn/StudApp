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

        currentHistoryToken = currentTarget.mergedHistoryTokens?.last
    }

    func latestCommonHistoryToken(in targets: [Targets]) -> NSPersistentHistoryToken? {
        return targets
            .flatMap { $0.mergedHistoryTokens?.reversed() }
            .firstCommonElement(type: NSPersistentHistoryToken.self)
    }

    func deleteHistoryTokens(in targets: inout [Targets], before token: NSPersistentHistoryToken) {
        for (index, target) in targets.enumerated() {
            guard let mergedHistoryTokens = target.mergedHistoryTokens,
                let tokenIndex = mergedHistoryTokens.index(of: token) else { continue }
            targets[index].mergedHistoryTokens = Array(mergedHistoryTokens.dropFirst(tokenIndex))
        }
    }

    func deleteHistory(before token: NSPersistentHistoryToken, in context: NSManagedObjectContext) throws {
        let deleteHistoryRequest = NSPersistentHistoryChangeRequest.deleteHistory(before: token)
        try context.execute(deleteHistoryRequest)
    }

    public func deleteMergedHistoryAndTokens(in targets: inout [Targets], in context: NSManagedObjectContext) throws {
        guard let token = latestCommonHistoryToken(in: targets) else { return }
        try deleteHistory(before: token, in: context)
        deleteHistoryTokens(in: &targets, before: token)
    }

    public func mergeHistory(into context: NSManagedObjectContext) throws {
        let historyFetchRequest = NSPersistentHistoryChangeRequest.fetchHistory(after: currentHistoryToken)
        guard let historyResult = try context.execute(historyFetchRequest) as? NSPersistentHistoryResult,
            let history = historyResult.result as? [NSPersistentHistoryTransaction] else {
            fatalError("Cannot convert persistent history fetch result to transaction.")
        }

        var mergedHistoryTokens = currentTarget.mergedHistoryTokens

        for transaction in history {
            context.mergeChanges(fromContextDidSave: transaction.objectIDNotification())
            mergedHistoryTokens?.append(transaction.token)
        }

        currentTarget.mergedHistoryTokens = mergedHistoryTokens
        currentHistoryToken = mergedHistoryTokens?.last ?? currentHistoryToken
    }
}
