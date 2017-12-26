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
        let authenticationRealm = storageService.defaults.string(forKey: UserDefaults.authenticationRealm)

        self.api = api ?? Api<StudIpRoutes>(baseUrl: apiUrl, realm: authenticationRealm)
    }

    /// Whether the user is currently signed in.
    ///
    /// - Warning: This does not garantuee that the credential is actually correct as this implementation only relies on a
    ///            credential being stored. Thus, the password might have changed in the meantime.
    public var isSignedIn: Bool {
        guard let protectionSpace = api.protectionSpace,
            let credential = URLCredentialStorage.shared.defaultCredential(for: protectionSpace),
            let user = credential.user
        else { return false }
        return !user.isEmpty
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
    func signIn(withUsername username: String, password: String, into organization: OrganizationRecord,
                handler: @escaping ResultHandler<User>) {
        api.baseUrl = organization.apiUrl
        api.realm = organization.authenticationRealm

        guard let protectionSpace = api.protectionSpace else {
            fatalError("Cannot create protection space for API.")
        }

        if let credential = URLCredentialStorage.shared.defaultCredential(for: protectionSpace) {
            URLCredentialStorage.shared.remove(credential, for: protectionSpace)
        }

        let credential = URLCredential(user: username, password: password, persistence: .forSession)
        URLCredentialStorage.shared.setDefaultCredential(credential, for: protectionSpace)

        api.request(.discovery) { result in
            URLCredentialStorage.shared.remove(credential, for: protectionSpace)

            guard result.isSuccess else { return handler(result.replacingValue(nil)) }

            let validatedCredential = URLCredential(user: username, password: password, persistence: .permanent)
            URLCredentialStorage.shared.setDefaultCredential(validatedCredential, for: protectionSpace)

            let storageService = ServiceContainer.default[StorageService.self]
            storageService.defaults.set(self.api.baseUrl, forKey: UserDefaults.apiUrl)
            storageService.defaults.set(self.api.realm, forKey: UserDefaults.authenticationRealm)

            let coreDataService = ServiceContainer.default[CoreDataService.self]
            User.updateCurrent(in: coreDataService.viewContext) { result in
                handler(result.replacingValue(result.value))
            }

            if #available(iOSApplicationExtension 11.0, *) {
                NSFileProviderManager.default.signalEnumerator(for: .rootContainer) { _ in }
            }
        }
    }

    /// Removes the default credential used for authentication, replaces it with an empty credential, and clears the data base.
    func signOut() {
        if let protectionSpace = api.protectionSpace {
            guard let credential = URLCredentialStorage.shared.defaultCredential(for: protectionSpace) else { return }
            URLCredentialStorage.shared.remove(credential, for: protectionSpace)

            let emptyCredential = URLCredential(user: "", password: "", persistence: .permanent)
            URLCredentialStorage.shared.setDefaultCredential(emptyCredential, for: protectionSpace)
        }

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
    }
}
