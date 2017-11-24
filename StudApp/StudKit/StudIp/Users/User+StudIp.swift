//
//  User+StudIp.swift
//  StudKit
//
//  Created by Steffen Ryll on 24.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

extension User {
    public var isCurrent: Bool {
        let studIpService = ServiceContainer.default[StudIpService.self]
        return id == studIpService.currentUserId
    }

    public func makeCurrent() {
        let studIpService = ServiceContainer.default[StudIpService.self]
        studIpService.currentUserId = id
    }

    static func fetchCurrent(in context: NSManagedObjectContext) throws -> User? {
        let studIpService = ServiceContainer.default[StudIpService.self]
        guard let currentUserId = studIpService.currentUserId else { return nil }
        return try fetch(byId: currentUserId, in: context)
    }

    static func updateCurrent(in context: NSManagedObjectContext, handler: @escaping ResultHandler<User>) {
        let studIp = ServiceContainer.default[StudIpService.self]
        studIp.api.requestDecoded(.currentUser) { (result: Result<UserResponse>) in
            User.update(using: result, in: context) { userResult in
                userResult.value?.makeCurrent()
                handler(userResult)
            }
        }
    }
}
