//
//  StudIpService.swift
//  StudKit
//
//  Created by Steffen Ryll on 22.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreSpotlight

public class StudIpService {
    let api: Api<StudIpRoutes>

    init(api: Api<StudIpRoutes>) {
        self.api = api
    }

    convenience init() {
        self.init(api: Api<StudIpRoutes>())

        guard let currentUser = User.current else { return }
        let oAuth1 = try? OAuth1<StudIpOAuth1Routes>(fromPersistedService: currentUser.objectIdentifier.rawValue)
        let apiUrl = currentUser.organization.apiUrl
        oAuth1?.baseUrl = apiUrl

        api.baseUrl = apiUrl
        api.authorizing = oAuth1
    }

    /// Whether the user is currently signed in.
    ///
    /// - Warning: This does not garantuee that the credential is actually correct as this implementation only relies on a
    ///            credential being stored. Thus, the password might have changed in the meantime.
    public var isSignedIn: Bool {
        return api.authorizing?.isAuthorized ?? false
    }

    func sign(into organization: Organization, authorizing: ApiAuthorizing, completion: @escaping ResultHandler<User>) {
        let coreDataService = ServiceContainer.default[CoreDataService.self]
        var persistableApiAuthorizing = authorizing as? PersistableApiAuthorizing

        signOut()

        api.baseUrl = organization.apiUrl
        api.authorizing = authorizing

        User.updateCurrent(organization: organization, in: coreDataService.viewContext) { result in
            guard result.isSuccess else {
                self.signOut()
                return completion(result)
            }

            User.current = result.value
            persistableApiAuthorizing?.service = result.value?.objectIdentifier.rawValue
            try? persistableApiAuthorizing?.persistCredentials()
            try? coreDataService.viewContext.saveAndWaitWhenChanged()

            if #available(iOSApplicationExtension 11.0, *) {
                NSFileProviderManager.default.signalEnumerator(for: .rootContainer) { _ in }
            }

            completion(result)
        }
    }

    /// Removes the default credential used for authentication, replaces it with an empty credential, and clears the database.
    func signOut() {
        User.current = nil

        api.baseUrl = nil
        api.removeLastRouteAccesses()
        try? (api.authorizing as? PersistableApiAuthorizing)?.removeCredentials()

        let coreDataService = ServiceContainer.default[CoreDataService.self]
        try? coreDataService.removeAllObjects(in: coreDataService.viewContext)
        try? coreDataService.viewContext.saveAndWaitWhenChanged()

        let storageService = ServiceContainer.default[StorageService.self]
        try? storageService.removeAllDownloads()

        CSSearchableIndex.default().deleteAllSearchableItems { _ in }

        if #available(iOSApplicationExtension 11.0, *) {
            NSFileProviderManager.default.signalEnumerator(for: .rootContainer) { _ in }
            NSFileProviderManager.default.signalEnumerator(for: .workingSet) { _ in }
        }
    }
}
