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
        return id == studIpService.userId
    }

    public func makeCurrent() {
        let studIpService = ServiceContainer.default[StudIpService.self]
        studIpService.userId = id
    }

    static func fetchCurrent(in context: NSManagedObjectContext) throws -> User? {
        let studIpService = ServiceContainer.default[StudIpService.self]
        guard let currentUserId = studIpService.userId else { return nil }
        return try fetch(byId: currentUserId, in: context)
    }

    static func updateCurrent(in context: NSManagedObjectContext, completion: @escaping ResultHandler<User>) {
        var organization: Organization! // TODO

        let studIpService = ServiceContainer.default[StudIpService.self]
        studIpService.api.requestDecoded(.currentUser) { (result: Result<UserResponse>) in
            let result = result.map { try $0.coreDataObject(organization: organization, in: context) }
            result.value?.makeCurrent()
            completion(result)
        }
    }
}
