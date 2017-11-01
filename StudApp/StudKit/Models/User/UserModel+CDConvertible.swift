//
//  UserModel+CDConvertible.swift
//  StudKit
//
//  Created by Steffen Ryll on 07.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

extension UserModel : CDConvertible {
    @discardableResult
    func coreDataModel(in context: NSManagedObjectContext) throws -> NSManagedObject {
        let user = try User.fetch(byId: id, orCreateIn: context)
        user.id = id
        user.username = username
        user.givenName = givenName
        user.familyName = familyName
        user.namePrefix = namePrefix
        user.nameSuffix = nameSuffix
        user.pictureModificationDate = pictureModificationDate
        return user
    }
}
