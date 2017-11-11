//
//  StudIpService.swift
//  StudKit
//
//  Created by Steffen Ryll on 22.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

final class StudIpService {
    let api: Api<StudIpRoutes>

    init(baseUrl: URL, realm: String) {
        api = Api<StudIpRoutes>(baseUrl: baseUrl, realm: realm)
    }

    init(api: Api<StudIpRoutes>) {
        self.api = api
    }

    /// Whether the user is currently signed in.
    ///
    /// - Warning: This does not garantuee that the credential is actually correct as this implementation only relies on a
    ///            credential being stored. Thus, the password might have changed in the meantime.
    var isSignedIn: Bool {
        return URLCredentialStorage.shared.defaultCredential(for: api.protectionSpace) != nil
    }

    /// Try to sign into Stud.IP using the credentials provided and update main data when successful.
    ///
    /// ## How it works
    ///  1. Create a new session credential with the provided username and password and save it as the default.
    ///  2. Request the password-protected discovery route, which provides information on available routes.
    ///  3. Remove session credential.
    ///  4. Abort if credential was rejected or another error occured during the request.
    ///  5. Create a permanent credential from the now validated username and password and save it as the default.
    ///  6. Update main data that is crucial for the application to work.
    ///
    /// - Parameters:
    ///   - username: Stud.IP username.
    ///   - password: Stud.IP password.
    ///   - handler: Completion handler that is called after *every* step finished.
    func signIn(withUsername username: String, password: String, handler: @escaping ResultHandler<Void>) {
        let credential = URLCredential(user: username, password: password, persistence: .forSession)
        URLCredentialStorage.shared.setDefaultCredential(credential, for: api.protectionSpace)

        api.request(.discovery) { result in
            URLCredentialStorage.shared.remove(credential, for: self.api.protectionSpace)

            guard result.isSuccess else {
                return handler(result.replacingValue(()))
            }

            let validatedCredential = URLCredential(user: username, password: password, persistence: .synchronizable)
            URLCredentialStorage.shared.setDefaultCredential(validatedCredential, for: self.api.protectionSpace)

            self.updateMainData(handler: handler)
        }
    }

    /// Update data, which is crucial for the application to work, e.g. semesters.
    func updateMainData(handler: @escaping ResultHandler<Void>) {
        let coreDataService = ServiceContainer.default[CoreDataService.self]
        let semesterService = ServiceContainer.default[SemesterService.self]

        coreDataService.performBackgroundTask { context in
            semesterService.updateSemesters(in: context) { result in
                handler(result.replacingValue(()))
            }
        }
    }
}
