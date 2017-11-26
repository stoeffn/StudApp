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

    init(folderId: String? = nil, fileId: String? = nil, name: String? = nil, coursePath: String,
         parentId: String? = nil, children: [FileResponse] = [], title: String, creationDate: Date = Date(),
         modificationDate: Date = Date(), size: Int? = nil, downloadCount: Int? = nil, ownerPath: String? = nil) {
        self.folderId = folderId
        self.fileId = fileId
        filename = name
        self.coursePath = coursePath
        self.parentId = parentId
        self.children = children
        self.title = title
        createdAt = creationDate
        modifiedAt = modificationDate
        self.size = size
        self.downloadCount = downloadCount
        self.ownerPath = ownerPath
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        folderId = try values.decodeIfPresent(String.self, forKey: .folderId)
        fileId = try values.decodeIfPresent(String.self, forKey: .fileId)
        filename = try values.decodeIfPresent(String.self, forKey: .filename)
        coursePath = try values.decode(String.self, forKey: .coursePath)
        parentId = try values.decodeIfPresent(String.self, forKey: .parentId)
        title = try values.decode(String.self, forKey: .title)
        createdAt = try values.decode(Date.self, forKey: .createdAt)
        modifiedAt = try values.decode(Date.self, forKey: .modifiedAt)
        size = try values.decodeIfPresent(Int.self, forKey: .size)
        downloadCount = try values.decodeIfPresent(Int.self, forKey: .downloadCount)
        ownerPath = try values.decodeIfPresent(String.self, forKey: .ownerPath)

        if let childrenCollection = try? values.decodeIfPresent([String: FileResponse].self, forKey: .children),
            let children = childrenCollection?.values {
            self.children = Array(children)
        } else {
            children = []
        }
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
        guard let courseId = courseId, let course = try Course.fetch(byId: courseId, in: context) else { return nil }
        return course
    }

    func fetchParent(in context: NSManagedObjectContext) throws -> File? {
        guard let parentId = parentId, let file = try File.fetch(byId: parentId, in: context) else { return nil }
        return file
    }
}
