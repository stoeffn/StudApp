//
//  MockStudIpService.swift
//  StudKit
//
//  Created by Steffen Ryll on 21.02.18.
//  Copyright © 2018 Steffen Ryll. All rights reserved.
//

public final class MockStudIpService: StudIpService {
    private var mockResponses = MockResponses()

    init() {
        super.init(api: Api<StudIpRoutes>())

        let coreDataService = ServiceContainer.default[CoreDataService.self]
        try? coreDataService.removeAllObjects(in: coreDataService.viewContext)
        try? mockResponses.insert(into: coreDataService.viewContext)
    }

    public override var isSignedIn: Bool {
        return true
    }

    override var userId: String? {
        get { return mockResponses.currentUser.id }
        set {}
    }
}
