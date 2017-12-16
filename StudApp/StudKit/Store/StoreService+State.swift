//
//  StoreService+State.swift
//  StudKit
//
//  Created by Steffen Ryll on 13.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

extension StoreService {
    enum State {
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

        var isVerifiedByServer: Bool? {
            switch self {
            case .locked, .deferred:
                return nil
            case let .unlocked(validatedByServer):
                return validatedByServer
            case let .subscribed(_, validatedByServer):
                return validatedByServer
            }
        }

        var markedAsVerifiedByServer: State {
            switch self {
            case .locked, .deferred:
                return self
            case .unlocked:
                return .unlocked(validatedByServer: true)
            case let .subscribed(subscribedUntil, _):
                return .subscribed(until: subscribedUntil, validatedByServer: true)
            }
        }

        // MARK: - Persistence

        static var fromDefaults: State? {
            let storageService = ServiceContainer.default[StorageService.self]
            let decoder = ServiceContainer.default[JSONDecoder.self]
            guard
                let encodedState = storageService.defaults.data(forKey: UserDefaults.storeStateKey),
                let state = try? decoder.decode(State.self, from: encodedState)
            else { return nil }
            return state
        }

        func toDefaults() {
            let storageService = ServiceContainer.default[StorageService.self]
            let encoder = ServiceContainer.default[JSONEncoder.self]
            let encodedState = try? encoder.encode(self)
            storageService.defaults.set(encodedState, forKey: UserDefaults.storeStateKey)
        }
    }
}

// MARK: - Coding

extension StoreService.State: Codable {
    enum CodingKeys: String, CodingKey {
        case state
        case subscribedUntil
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let state = try container.decode(String.self, forKey: .state)

        switch state {
        case "locked":
            self = .locked
        case "deferred":
            self = .deferred
        case "unlocked":
            self = .unlocked(validatedByServer: false)
        case "subscribed":
            let subscribedUntil = try container.decode(Date.self, forKey: .subscribedUntil)
            self = .subscribed(until: subscribedUntil, validatedByServer: false)
        default:
            throw "Unknown state '\(state)'"
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .locked:
            try container.encode("locked", forKey: .state)
        case .deferred:
            try container.encode("deferred", forKey: .state)
        case .unlocked:
            try container.encode("unlocked", forKey: .state)
        case let .subscribed(until: subscribedUntil, _):
            try container.encode("subscribed", forKey: .state)
            try container.encode(subscribedUntil, forKey: .subscribedUntil)
        }
    }
}
