//
//  DocumentResponse.swift
//  StudKit
//
//  Created by Steffen Ryll on 16.02.18.
//  Copyright © 2018 Steffen Ryll. All rights reserved.
//

import CoreData
import MobileCoreServices

struct DocumentResponse: IdentifiableResponse {
    let id: String
    let userId: String?
    let name: String
    let createdAt: Date
    let modifiedAt: Date
    let summary: String?
    let size: Int?
    let downloadCount: Int?

    init(id: String, userId: String? = nil, name: String = "", createdAt: Date = .distantPast, modifiedAt: Date = .distantPast,
         summary: String? = nil, size: Int? = nil, downloadCount: Int? = nil) {
        self.id = id
        self.userId = userId
        self.name = name
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.summary = summary
        self.size = size
        self.downloadCount = downloadCount
    }
}

// MARK: - Coding

extension DocumentResponse: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case createdAt = "mkdate"
        case modifiedAt = "chdate"
        case summary = "description"
        case size
        case downloadCount = "downloads"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        userId = try container.decodeIfPresent(String.self, forKey: .userId)?.nilWhenEmpty
        name = try container.decode(String.self, forKey: .name)
        createdAt = try StudIp.decodeTimeIntervalStringAsDate(in: container, forKey: .createdAt)
        modifiedAt = try StudIp.decodeTimeIntervalStringAsDate(in: container, forKey: .modifiedAt)
        summary = try container.decodeIfPresent(String.self, forKey: .summary)?.nilWhenEmpty
        size = Int(try container.decodeIfPresent(String.self, forKey: .size) ?? "")
        downloadCount = Int(try container.decodeIfPresent(String.self, forKey: .downloadCount) ?? "")
    }
}

// MARK: - Converting to a Core Data Object

extension DocumentResponse {
    @discardableResult
    func coreDataObject(course: Course, parent: File, in context: NSManagedObjectContext) throws -> File {
        let (file, _) = try File.fetch(byId: id, orCreateIn: context)
        file.typeIdentifier = typeIdentifier
        file.course = course
        file.parent = parent
        file.owner = try User.fetch(byId: userId, in: context)
        file.name = name
        file.createdAt = createdAt
        file.modifiedAt = modifiedAt
        file.size = size ?? -1
        file.downloadCount = downloadCount ?? -1
        file.summary = summary
        return file
    }

    var typeIdentifier: String {
        guard let fileExtension = name.components(separatedBy: ".").last else { return "" }
        let typeIdentifier = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension as CFString, nil)
        return typeIdentifier?.takeRetainedValue() as String? ?? ""
    }
}
