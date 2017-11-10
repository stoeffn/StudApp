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

    var isSignedIn: Bool {
        return Defaults[.isSignedIn]
    }
    
    /// Try to sign into Stud.IP using the credentials provided.
    func signIn(withUsername username: String, password: String, handler: @escaping ResultHandler<Void>) {
        let credential = URLCredential(user: username, password: password, persistence: .forSession)
        URLCredentialStorage.shared.setDefaultCredential(credential, for: api.protectionSpace)
        
        api.request(.discovery) { result in
            guard result.isSuccess else {
                return handler(result.replacingValue(()))
            }

            let validatedCredential = URLCredential(user: username, password: password, persistence: .synchronizable)
            URLCredentialStorage.shared.setDefaultCredential(validatedCredential, for: self.api.protectionSpace)
            Defaults[.isSignedIn] = true

            self.updateMainData(handler: handler)
        }
    }

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
