//
//  StudIpService.swift
//  StudKit
//
//  Created by Steffen Ryll on 22.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreSpotlight

public final class StudIpService {
    let api: Api<StudIpRoutes>

    init(api: Api<StudIpRoutes>? = nil) {
        let storageService = ServiceContainer.default[StorageService.self]
        let apiUrl = storageService.defaults.url(forKey: UserDefaults.apiUrl)

        self.api = api ?? Api<StudIpRoutes>(baseUrl: apiUrl)
    }

    /// Whether the user is currently signed in.
    ///
    /// - Warning: This does not garantuee that the credential is actually correct as this implementation only relies on a
    ///            credential being stored. Thus, the password might have changed in the meantime.
    public var isSignedIn: Bool {
        return false
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

    func authorizationUrl(for organization: OrganizationRecord, handler: @escaping ResultHandler<URL>) {
        let oAuth1 = OAuth1<StudIpOAuth1Routes>(consumerKey: organization.consumerKey,
                                                consumerSecret: organization.consumerSecret)
        oAuth1.baseUrl = organization.oauthApiUrl
        oAuth1.createRequestToken { result in
            handler(result.replacingValue(oAuth1.authorizationUrl))
        }
    }

    /// Removes the default credential used for authentication, replaces it with an empty credential, and clears the data base.
    func signOut() {
        userId = nil

        api.removeLastRouteAccesses()

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

        fatalError("TODO")
    }
}
