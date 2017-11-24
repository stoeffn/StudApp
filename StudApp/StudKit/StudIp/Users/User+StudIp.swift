//
//  User+StudIp.swift
//  StudKit
//
//  Created by Steffen Ryll on 24.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

extension User {
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
