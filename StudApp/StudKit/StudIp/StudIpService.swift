//
//  StudIpService.swift
//  StudKit
//
//  Created by Steffen Ryll on 22.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreSpotlight

public final class StudIpService {
    static let serviceName = "studip"

    let api: Api<StudIpRoutes>

    init(api: Api<StudIpRoutes>) {
        self.api = api
    }

    convenience init() {
        self.init(api: Api<StudIpRoutes>())

        let oAuth1 = try? OAuth1<StudIpOAuth1Routes>(fromPersistedService: StudIpService.serviceName)
        oAuth1?.baseUrl = apiUrl

        api.baseUrl = apiUrl
        api.authorizing = oAuth1
    }

    var apiUrl: URL? {
        get {
            let storageService = ServiceContainer.default[StorageService.self]
            return storageService.defaults.url(forKey: UserDefaults.apiUrlKey)
        }
        set {
            let storageService = ServiceContainer.default[StorageService.self]
            storageService.defaults.set(newValue, forKey: UserDefaults.apiUrlKey)
        }
    }

    /// Stud.IP-id of the currently signed in user.
    var userId: String? {
        get {
            let storageService = ServiceContainer.default[StorageService.self]
            return storageService.defaults.string(forKey: UserDefaults.userIdKey)
        }
        set {
            let storageService = ServiceContainer.default[StorageService.self]
            storageService.defaults.set(newValue, forKey: UserDefaults.userIdKey)
        }
    }

    /// Whether the user is currently signed in.
    ///
    /// - Warning: This does not garantuee that the credential is actually correct as this implementation only relies on a
    ///            credential being stored. Thus, the password might have changed in the meantime.
    public var isSignedIn: Bool {
        return api.authorizing?.isAuthorized ?? false
    }

    func signIn(apiUrl: URL, authorizing: ApiAuthorizing, handler: @escaping ResultHandler<User>) {
        signOut()

        api.baseUrl = apiUrl
        api.authorizing = authorizing

        self.apiUrl = apiUrl
        try? (authorizing as? PersistableApiAuthorizing)?.persistCredentials()

        let coreDataService = ServiceContainer.default[CoreDataService.self]

        User.updateCurrent(in: coreDataService.viewContext) { result in
            guard result.isSuccess else {
                self.signOut()
                return handler(result.replacingValue(result.value))
            }

            if #available(iOSApplicationExtension 11.0, *) {
                NSFileProviderManager.default.signalEnumerator(for: .rootContainer) { _ in }
            }

            handler(result.replacingValue(result.value))
        }
    }

    /// Removes the default credential used for authentication, replaces it with an empty credential, and clears the database.
    func signOut() {
        userId = nil
        apiUrl = nil

        api.removeLastRouteAccesses()
        try? (api.authorizing as? PersistableApiAuthorizing)?.removeCredentials()

        let coreDataService = ServiceContainer.default[CoreDataService.self]
        try? coreDataService.removeAllObjects(in: coreDataService.viewContext)
        try? coreDataService.viewContext.saveWhenChanged()

        let storageService = ServiceContainer.default[StorageService.self]
        try? storageService.removeAllDownloads()

        CSSearchableIndex.default().deleteAllSearchableItems { _ in }

        if #available(iOSApplicationExtension 11.0, *) {
            NSFileProviderManager.default.signalEnumerator(for: .rootContainer) { _ in }
            NSFileProviderManager.default.signalEnumerator(for: .workingSet) { _ in }
        }
    }
}
