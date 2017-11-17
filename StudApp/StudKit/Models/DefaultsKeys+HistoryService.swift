//
//  DefaultsKeys+HistoryService.swift
//  StudKit
//
//  Created by Steffen Ryll on 17.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

extension DefaultsKeys {
    static let currentAppHistoryToken = DefaultsKey<Data>(Targets.app.rawValue)
    static let currentFileProviderHistoryToken = DefaultsKey<Data>(Targets.fileProvider.rawValue)
}

// MARK: Targets Utilities

extension Targets {
    var currentHistoryTokenUserDefaultsKey: DefaultsKey<Data>? {
        switch self {
        case .app: return DefaultsKeys.currentAppHistoryToken
        case .fileProvider: return DefaultsKeys.currentFileProviderHistoryToken
        default: return nil
        }
    }

    var currentHistoryToken: NSPersistentHistoryToken? {
        get {
            guard let key = currentHistoryTokenUserDefaultsKey else { return nil }
            let unarchiver = NSKeyedUnarchiver(forReadingWith: Defaults[key])
            unarchiver.requiresSecureCoding = true
            let token = unarchiver.decodeObject(of: NSPersistentHistoryToken.self, forKey: NSKeyedArchiveRootObjectKey)
            unarchiver.finishDecoding()
            return token
        }
        set {
            guard let key = currentHistoryTokenUserDefaultsKey else { return }
            let data = NSMutableData()
            let archiver = NSKeyedArchiver(forWritingWith: data)
            archiver.requiresSecureCoding = true
            archiver.finishEncoding()
            Defaults[key] = data as Data
        }
    }
}
