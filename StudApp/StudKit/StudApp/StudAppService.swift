//
//  StudAppService.swift
//  StudKit
//
//  Created by Steffen Ryll on 16.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

final class StudAppService {
    let api: Api<StudAppRoutes>

    init(api: Api<StudAppRoutes>? = nil, baseUrl: URL) {
        self.api = api ?? Api<StudAppRoutes>()
        self.api.baseUrl = baseUrl
    }
}
