//
//  DocumentResponse.swift
//  StudKit
//
//  Created by Steffen Ryll on 16.02.18.
//  Copyright © 2018 Steffen Ryll. All rights reserved.
//

import MobileCoreServices

struct DocumentResponse: IdentifiableResponse {
    let id: String
    let parentId: String
    let userId: String?
    let name: String
    let createdAt: Date
    let modifiedAt: Date
    let summary: String?
    let size: Int?
    let downloadCount: Int?
}

// MARK: - Coding

extension DocumentResponse: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case parentId = "folder_id"
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
        parentId = try container.decode(String.self, forKey: .parentId)
        userId = try container.decode(String.self, forKey: .userId)
        name = try container.decode(String.self, forKey: .name)
        createdAt = try StudIp.decodeTimeIntervalStringAsDate(in: container, forKey: .createdAt)
        modifiedAt = try StudIp.decodeTimeIntervalStringAsDate(in: container, forKey: .modifiedAt)
        summary = try container.decodeIfPresent(String.self, forKey: .summary)?.nilWhenEmpty
        size = Int(try container.decodeIfPresent(String.self, forKey: .size) ?? "")
        downloadCount = Int(try container.decodeIfPresent(String.self, forKey: .downloadCount) ?? "")
    }
}

// MARK: - Utilities

extension DocumentResponse {
    var typeIdentifier: String {
        guard let fileExtension = name.components(separatedBy: ".").last else { return "" }
        let typeIdentifier = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension as CFString, nil)
        return typeIdentifier?.takeRetainedValue() as String? ?? ""
    }
}
