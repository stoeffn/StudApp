//
//  DocumentResponse+CDConvertible.swift
//  StudKit
//
//  Created by Steffen Ryll on 16.02.18.
//  Copyright © 2018 Steffen Ryll. All rights reserved.
//

import CoreData

extension DocumentResponse: CDConvertible {
    func coreDataObject(in context: NSManagedObjectContext) throws -> NSManagedObject {
        let (file, _) = try File.fetch(byId: id, orCreateIn: context)
        file.id = id
        file.typeIdentifier = typeIdentifier
        file.parent = try File.fetch(byId: parentId, in: context)
        file.owner = try User.fetch(byId: userId, in: context)
        file.name = name
        file.createdAt = createdAt
        file.modifiedAt = modifiedAt
        file.size = size ?? -1
        file.downloadCount = downloadCount ?? -1
        file.summary = summary
        return file
    }
}
