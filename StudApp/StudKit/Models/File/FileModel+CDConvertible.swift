//
//  FileModel+CDConvertible.swift
//  StudKit
//
//  Created by Steffen Ryll on 27.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

extension FileModel: CDConvertible {
    @discardableResult
    func coreDataModel(in context: NSManagedObjectContext) throws -> NSManagedObject {
        guard let id = id, let name = name, let course = try fetchCourse(in: context) else {
            throw "Cannot create file core data model from invalid file model."
        }
        let (file, _) = try File.fetch(byId: id, orCreateIn: context)
        file.id = id
        file.typeIdentifier = typeIdentifier
        file.course = course
        file.parent = try fetchParent(in: context)
        file.title = title
        file.name = name
        file.creationDate = creationDate
        file.modificationDate = modificationDate
        file.size = size ?? -1
        file.numberOfDownloads = numberOfDownloads ?? -1
        file.owner = try User.fetch(byId: ownerId, in: context)
        file.children = try children
            .flatMap { try $0.coreDataModel(in: context) as? File }
            .set
        return file
    }
}
