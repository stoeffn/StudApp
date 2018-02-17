//
//  UserResponse.swift
//  StudKit
//
//  Created by Steffen Ryll on 07.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

struct UserResponse: IdentifiableResponse {
    let id: String
    let username: String
    let givenName: String
    let familyName: String
    let namePrefix: String?
    let nameSuffix: String?
    let pictureUrl: URL?

    init(id: String, username: String = "", givenName: String = "", familyName: String = "", namePrefix: String? = nil,
         nameSuffix: String? = nil, pictureUrl: URL? = nil) {
        self.id = id
        self.username = username
        self.givenName = givenName
        self.familyName = familyName
        self.namePrefix = namePrefix
        self.nameSuffix = nameSuffix
        self.pictureUrl = pictureUrl
    }
}

// MARK: - Coding

extension UserResponse: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case pictureUrl = "avatar_normal"
    }

    enum NameKeys: String, CodingKey {
        case username
        case given
        case family
        case prefix
        case suffix
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? container.decode(String.self, forKey: .userId)
        pictureUrl = try container.decodeIfPresent(URL.self, forKey: .pictureUrl)

        let nameContainer = try container.nestedContainer(keyedBy: NameKeys.self, forKey: .name)
        username = try nameContainer.decode(String.self, forKey: .username)
        givenName = try nameContainer.decode(String.self, forKey: .given)
        familyName = try nameContainer.decode(String.self, forKey: .family)
        namePrefix = try nameContainer.decodeIfPresent(String.self, forKey: .prefix)?.nilWhenEmpty
        nameSuffix = try nameContainer.decodeIfPresent(String.self, forKey: .suffix)?.nilWhenEmpty
    }
}

// MARK: - Converting to a Core Data Object

extension UserResponse {
    @discardableResult
    func coreDataObject(in context: NSManagedObjectContext) throws -> User {
        let (user, _) = try User.fetch(byId: id, orCreateIn: context)
        user.username = username
        user.givenName = givenName
        user.familyName = familyName
        user.namePrefix = namePrefix
        user.nameSuffix = nameSuffix
        user.pictureModifiedAt = pictureModifiedAt
        return user
    }

    var pictureModifiedAt: Date? {
        guard let url = pictureUrl,
            !url.path.contains("/nobody_"),
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let timestampString = components.queryItems?.first?.value,
            let timestamp = Double(timestampString)
            else { return nil }
        return Date(timeIntervalSince1970: timestamp)
    }
}
