//
//  Targets+NSPersistentHistory.swift
//  StudKit
//
//  Created by Steffen Ryll on 17.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

extension Targets {
    var lastHistoryTransactionTimestampKey: String? {
        switch self {
        case .app: return "historyTokensMergedIntoApp"
        case .fileProvider: return "historyTokensMergedIntoFileProvider"
        default: return nil
        }
    }

    var lastHistoryTransactionTimestamp: Date? {
        get {
            let storageService = ServiceContainer.default[StorageService.self]
            guard let defaults = storageService.defaults,
                let key = lastHistoryTransactionTimestampKey else { return nil }
            return defaults.object(forKey: key) as? Date
        }
        set {
            let storageService = ServiceContainer.default[StorageService.self]
            guard let defaults = storageService.defaults,
                let key = lastHistoryTransactionTimestampKey else { return }
            defaults.set(newValue, forKey: key)
        }
    }
}
