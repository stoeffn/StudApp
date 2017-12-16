//
//  FileResponse.swift
//  StudKit
//
//  Created by Steffen Ryll on 22.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import MobileCoreServices
import CoreData

struct FileResponse: Decodable {
    private let folderId: String?
    private let fileId: String?
    private let filename: String?
    private let coursePath: String
    private let parentId: String?
    let children: [FileResponse]
    let title: String
    let createdAt: Date
    let modifiedAt: Date
    let size: Int?
    let downloadCount: Int?
    private let ownerPath: String?

    enum CodingKeys: String, CodingKey {
        case folderId = "folder_id"
        case fileId = "file_id"
        case filename
        case coursePath = "course"
        case parentId = "range_id"
        case children = "documents"
        case title = "name"
        case createdAt = "mkdate"
        case modifiedAt = "chdate"
        case size = "filesize"
        case downloadCount = "downloads"
        case ownerPath = "author"
    }

    init(folderId: String? = nil, fileId: String? = nil, filename: String? = nil, coursePath: String,
         parentId: String? = nil, children: [FileResponse] = [], title: String, createdAt: Date = Date(),
         modifiedAt: Date = Date(), size: Int? = nil, downloadCount: Int? = nil, ownerPath: String? = nil) {
        self.folderId = folderId
        self.fileId = fileId
        self.filename = filename
        self.coursePath = coursePath
        self.parentId = parentId
        self.children = children
        self.title = title
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.size = size
        self.downloadCount = downloadCount
        self.ownerPath = ownerPath
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        folderId = try container.decodeIfPresent(String.self, forKey: .folderId)
        fileId = try container.decodeIfPresent(String.self, forKey: .fileId)
        filename = try container.decodeIfPresent(String.self, forKey: .filename)
        coursePath = try container.decode(String.self, forKey: .coursePath)
        parentId = try container.decodeIfPresent(String.self, forKey: .parentId)
        title = try container.decode(String.self, forKey: .title)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        modifiedAt = try container.decode(Date.self, forKey: .modifiedAt)
        size = try container.decodeIfPresent(Int.self, forKey: .size)
        downloadCount = try container.decodeIfPresent(Int.self, forKey: .downloadCount)
        ownerPath = try container.decodeIfPresent(String.self, forKey: .ownerPath)

        guard
            let childrenCollection = try? container.decodeIfPresent([String: FileResponse].self, forKey: .children),
            let children = childrenCollection?.values
        else {
            self.children = []
            return
        }

        self.children = Array(children)
    }
}

// MARK: - Utilities

extension FileResponse {
    var id: String? {
        return isFolder ? folderId : fileId
    }

    var courseId: String? {
        return StudIp.transformIdPath(coursePath)
    }

    var ownerId: String? {
        return StudIp.transformIdPath(ownerPath)
    }

    var isFolder: Bool {
        return folderId != nil
    }

    var typeIdentifier: String {
        if isFolder {
            return kUTTypeFolder as String
        }
        guard let fileExtension = filename?.components(separatedBy: ".").last else { return "" }
        let typeIdentifier = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension as CFString, nil)
        return typeIdentifier?.takeRetainedValue() as String? ?? ""
    }

    var name: String? {
        return isFolder ? title : filename
    }

    func fetchCourse(in context: NSManagedObjectContext) throws -> Course? {
        guard
            let courseId = courseId,
            let course = try Course.fetch(byId: courseId, in: context)
        else { return nil }
        return course
    }

    func fetchParent(in context: NSManagedObjectContext) throws -> File? {
        guard let parentId = parentId,
            let file = try File.fetch(byId: parentId, in: context)
        else { return nil }
        return file
    }
}
