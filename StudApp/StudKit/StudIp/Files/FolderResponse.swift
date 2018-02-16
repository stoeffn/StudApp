//
//  FolderResponse.swift
//  StudKit
//
//  Created by Steffen Ryll on 16.02.18.
//  Copyright © 2018 Steffen Ryll. All rights reserved.
//

struct FolderResponse: IdentifiableResponse {
    let id: String
    let courseId: String
    let parentId: String?
    let userId: String?
    let name: String
    let createdAt: Date
    let modifiedAt: Date
    let summary: String?
    let folders: Set<FolderResponse>
    let documents: Set<DocumentResponse>

    init(id: String, courseId: String, parentId: String? = nil, userId: String? = nil, name: String = "",
         createdAt: Date = .distantPast, modifiedAt: Date = .distantPast, summary: String? = nil,
         folders: Set<FolderResponse> = [], documents: Set<DocumentResponse> = []) {
        self.id = id
        self.courseId = courseId
        self.parentId = parentId
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
        case parentId = "parent_id"
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
        parentId = try container.decode(String.self, forKey: .parentId).nilWhenEmpty
        userId = try container.decodeIfPresent(String.self, forKey: .userId)?.nilWhenEmpty
        name = try container.decode(String.self, forKey: .name)
        createdAt = try StudIp.decodeTimeIntervalStringAsDate(in: container, forKey: .createdAt)
        modifiedAt = try StudIp.decodeTimeIntervalStringAsDate(in: container, forKey: .modifiedAt)
        summary = try container.decodeIfPresent(String.self, forKey: .summary)?.nilWhenEmpty
        folders = try container.decodeIfPresent(Set<FolderResponse>.self, forKey: .folders) ?? []
        documents = try container.decodeIfPresent(Set<DocumentResponse>.self, forKey: .documents) ?? []
    }
}
