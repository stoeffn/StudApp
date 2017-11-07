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
    
    func signIn(withUsername username: String, password: String, handler: @escaping ResultHandler<Void>) {
        // TODO: Research a more professional way for changing session credentials.
        api.session = URLSession(credentials: ApiCredentials(username: username, password: password))
        api.request(.discovery) { result in
            handler(result.replacingValue(()))
            // TODO: Save credentials.
        }
    }
}
