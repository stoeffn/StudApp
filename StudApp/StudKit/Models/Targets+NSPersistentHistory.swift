//
//  Targets+NSPersistentHistory.swift
//  StudKit
//
//  Created by Steffen Ryll on 17.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

extension Targets {
    /// Timestamp of the last Core Data persistent history merge into the target's view context.
    var lastHistoryTransactionTimestamp: Date? {
        get {
            let storageService = ServiceContainer.default[StorageService.self]
            let key = UserDefaults.lastHistoryTransactionTimestampKey(for: self)
            return storageService.defaults.object(forKey: key) as? Date
        }
        set {
            let storageService = ServiceContainer.default[StorageService.self]
            let key = UserDefaults.lastHistoryTransactionTimestampKey(for: self)
            storageService.defaults.set(newValue, forKey: key)
        }
    }
}
