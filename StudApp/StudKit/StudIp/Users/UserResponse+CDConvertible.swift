//
//  UserResponse+CDConvertible.swift
//  StudKit
//
//  Created by Steffen Ryll on 07.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

extension UserResponse: CDConvertible {
    @discardableResult
    func coreDataObject(in context: NSManagedObjectContext) throws -> NSManagedObject {
        let (user, _) = try User.fetch(byId: id, orCreateIn: context)
        user.id = id
        user.username = username
        user.givenName = givenName
        user.familyName = familyName
        user.namePrefix = namePrefix
        user.nameSuffix = nameSuffix
        user.pictureModifiedAt = pictureModifiedAt
        return user
    }
}
