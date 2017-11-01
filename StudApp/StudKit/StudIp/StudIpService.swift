//
//  StudIpService.swift
//  StudKit
//
//  Created by Steffen Ryll on 22.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

final class StudIpService {
    private static let url = URL(string: "https://studip.uni-hannover.de/api.php")!

    typealias Routes = StudIpRoutes
    let api: Api<StudIpRoutes>

    init(api: Api<StudIpRoutes>) {
        self.api = api
    }
    
    init(credentials: ApiCredentials) {
        api = Api<StudIpRoutes>(baseUrl: StudIpService.url, credentials: credentials)
    }
}
