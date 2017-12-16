//
//  StoreService+State.swift
//  StudKit
//
//  Created by Steffen Ryll on 13.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

extension StoreService {
    enum State: RawRepresentable {
        typealias RawValue = (state: String, subscribedUntilTimestamp: TimeInterval?)

        case locked

        case deferred

        case unlocked(validatedByServer: Bool)

        case subscribed(until: Date, validatedByServer: Bool)

        // MARK: - Utilities

        var isUnlocked: Bool {
            switch self {
            case .locked, .deferred:
                return false
            case .unlocked, .subscribed:
                return true
            }
        }

        var isDeferred: Bool {
            guard case .deferred = self else { return false }
            return true
        }

        // MARK: - Coding

        init?(rawValue: RawValue) {
            switch rawValue.state {
            case "locked":
                self = .locked
            case "deferred":
                self = .deferred
            case "unlocked":
                self = .unlocked(validatedByServer: false)
            case "subscribed":
                guard let subscribedUntilTimestamp = rawValue.subscribedUntilTimestamp else { return nil }
                self = .subscribed(until: Date(timeIntervalSince1970: subscribedUntilTimestamp), validatedByServer: false)
            default:
                return nil
            }
        }

        var rawValue: RawValue {
            switch self {
            case .locked:
                return (state: "locked", subscribedUntilTimestamp: nil)
            case .deferred:
                return (state: "deferred", subscribedUntilTimestamp: nil)
            case .unlocked:
                return (state: "unlocked", subscribedUntilTimestamp: nil)
            case let .subscribed(until: subscribedUntil, _):
                return (state: "subscribed", subscribedUntilTimestamp: subscribedUntil.timeIntervalSince1970)
            }
        }

        // MARK: - Persistence

        static var fromDefaults: State? {
            let storageService = ServiceContainer.default[StorageService.self]
            guard let state = storageService.defaults.string(forKey: UserDefaults.storeStateKey) else { return nil }
            let subscribedUntilTimestamp = storageService.defaults.double(forKey: UserDefaults.storeStateSubscribedUntilKey)
            return State(rawValue: (state: state, subscribedUntilTimestamp: subscribedUntilTimestamp))
        }

        func toDefaults() {
            let storageService = ServiceContainer.default[StorageService.self]
            storageService.defaults.set(rawValue.state, forKey: UserDefaults.storeStateKey)
            storageService.defaults.set(rawValue.subscribedUntilTimestamp, forKey: UserDefaults.storeStateSubscribedUntilKey)
        }
    }
}
