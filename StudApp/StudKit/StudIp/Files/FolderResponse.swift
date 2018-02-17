//
//  FolderResponse.swift
//  StudKit
//
//  Created by Steffen Ryll on 16.02.18.
//  Copyright © 2018 Steffen Ryll. All rights reserved.
//

import CoreData
import MobileCoreServices

struct FolderResponse: IdentifiableResponse {
    let id: String
    let courseId: String
    let userId: String?
    let name: String
    let createdAt: Date
    let modifiedAt: Date
    let summary: String?
    let folders: Set<FolderResponse>?
    let documents: Set<DocumentResponse>?

    init(id: String, courseId: String, userId: String? = nil, name: String = "",
         createdAt: Date = .distantPast, modifiedAt: Date = .distantPast, summary: String? = nil,
         folders: Set<FolderResponse>? = nil, documents: Set<DocumentResponse>? = nil) {
        self.id = id
        self.courseId = courseId
        self.userId = userId
        self.name = name
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.summary = summary
        self.folders = folders
        self.documents = documents
    }
}

// MARK: - Coding

extension FolderResponse: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case courseId = "range_id"
        case userId = "user_id"
        case name
        case createdAt = "mkdate"
        case modifiedAt = "chdate"
        case summary = "description"
        case folders = "subfolders"
        case documents = "file_refs"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        courseId = try container.decode(String.self, forKey: .courseId)
        userId = try container.decodeIfPresent(String.self, forKey: .userId)?.nilWhenEmpty
        name = try container.decode(String.self, forKey: .name)
        createdAt = try StudIp.decodeTimeIntervalStringAsDate(in: container, forKey: .createdAt)
        modifiedAt = try StudIp.decodeTimeIntervalStringAsDate(in: container, forKey: .modifiedAt)
        summary = try container.decodeIfPresent(String.self, forKey: .summary)?.nilWhenEmpty
        folders = try container.decodeIfPresent(Set<FolderResponse>.self, forKey: .folders)
        documents = try container.decodeIfPresent(Set<DocumentResponse>.self, forKey: .documents)
    }
}

// MARK: - Converting to a Core Data Object

extension FolderResponse {
    func coreDataObject(course: Course, parent: File? = nil, in context: NSManagedObjectContext) throws -> File {
        let (file, _) = try File.fetch(byId: id, orCreateIn: context)
        let folders = try self.folders(file: file, course: course, in: context)
        let documents = try self.documents(file: file, course: course, in: context)
        file.id = id
        file.typeIdentifier = kUTTypeFolder as String
        file.parent = parent
        file.course = course
        file.owner = try User.fetch(byId: userId, in: context)
        file.name = name
        file.createdAt = createdAt
        file.modifiedAt = modifiedAt
        file.size = -1
        file.downloadCount = -1
        file.summary = summary
        file.children = Set(folders).union(documents)
        return file
    }

    func folders(file: File, course: Course, in context: NSManagedObjectContext) throws -> [File] {
        guard let folders = folders else { return [] }
        return try File.update(file.childFoldersFetchRequest, with: folders, in: context) { response in
            try response.coreDataObject(course: course, parent: file, in: context)
        }
    }

    func documents(file: File, course: Course, in context: NSManagedObjectContext) throws -> [File] {
        guard let documents = documents else { return [] }
        return try File.update(file.childDocumentsFetchRequest, with: documents, in: context) { response in
            try response.coreDataObject(course: course, parent: file, in: context)
        }
    }
}
