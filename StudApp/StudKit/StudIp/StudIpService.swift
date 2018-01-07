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
        fatalError("TODO")
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

    /// Tries to sign into Stud.IP using the credentials provided.
    ///
    /// ## How it works
    ///  0. Remove current default credential if set.
    ///  1. Create a new session credential with the provided username and password and save it as the default.
    ///  2. Request the password-protected discovery route, which provides information on available routes.
    ///  3. Remove session credential.
    ///  4. Abort if credential was rejected or another error occured during the request.
    ///  5. Create a permanent credential from the now validated username and password and save it as the default.
    ///  6. Save the API base `URL` and authentication realm.
    ///  7. Fetch the current user from the API and mark as the current user.
    ///  8. Signal the root container that there are updates
    ///
    /// - Parameters:
    ///   - username: Stud.IP username.
    ///   - password: Stud.IP password.
    ///   - organization: Organization, which contains the API URL, to sign into.
    ///   - handler: Completion handler that is called after *every* step finished.
    func signIn(withUsername _: String, password _: String, into organization: OrganizationRecord,
                handler: @escaping ResultHandler<User>) {
        api.baseUrl = organization.apiUrl

        api.request(.discovery) { result in
            guard result.isSuccess else { return handler(result.replacingValue(nil)) }

            let storageService = ServiceContainer.default[StorageService.self]
            storageService.defaults.set(self.api.baseUrl, forKey: UserDefaults.apiUrl)

            let coreDataService = ServiceContainer.default[CoreDataService.self]
            User.updateCurrent(in: coreDataService.viewContext) { result in
                handler(result.replacingValue(result.value))
            }

            if #available(iOSApplicationExtension 11.0, *) {
                NSFileProviderManager.default.signalEnumerator(for: .rootContainer) { _ in }
            }
        }

        fatalError("TODO")
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
