//
//  StudIpService.swift
//  StudKit
//
//  Created by Steffen Ryll on 22.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

final class StudIpService {
    let api: Api<StudIpRoutes>
    
    init(baseUrl: URL) {
        api = Api<StudIpRoutes>(baseUrl: baseUrl)
    }

    init(api: Api<StudIpRoutes>) {
        self.api = api
    }
    
    /// Try to sign into Stud.IP using the credentials provided.
    func signIn(withUsername username: String, password: String, handler: @escaping ResultHandler<Void>) {
        let credential = URLCredential(user: username, password: password, persistence: .forSession)
        URLCredentialStorage.shared.setDefaultCredential(credential, for: api.protectionSpace)
        
        api.request(.discovery) { result in
            if result.isSuccess {
                let validatedCredential = URLCredential(user: username, password: password, persistence: .synchronizable)
                URLCredentialStorage.shared.setDefaultCredential(validatedCredential, for: self.api.protectionSpace)
            }
            handler(result.replacingValue(()))
        }
    }
}
