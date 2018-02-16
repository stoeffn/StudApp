//
//  FolderResponse+CDConvertible.swift
//  StudKit
//
//  Created by Steffen Ryll on 16.02.18.
//  Copyright © 2018 Steffen Ryll. All rights reserved.
//

import CoreData
import MobileCoreServices

extension FolderResponse: CDConvertible {
    func coreDataObject(in context: NSManagedObjectContext) throws -> NSManagedObject {
        let (file, _) = try File.fetch(byId: id, orCreateIn: context)
        let folders = try self.folders
            .flatMap { try $0.coreDataObject(in: context) as? File }
        let documents = try self.documents
            .flatMap { try $0.coreDataObject(in: context) as? File }
        file.id = id
        file.typeIdentifier = kUTTypeFolder as String
        file.parent = try File.fetch(byId: parentId, in: context)
        file.course = try Course.fetch(byId: courseId, in: context) ?? file.course
        file.owner = try User.fetch(byId: userId, in: context)
        file.name = name
        file.createdAt = createdAt
        file.modifiedAt = modifiedAt
        file.size = -1
        file.downloadCount = -1
        file.summary = summary
        file.children = Set(folders).union(documents)
        file.children.forEach { $0.course = file.course }
        return file
    }
}
