//
//  UserResponse.swift
//  StudKit
//
//  Created by Steffen Ryll on 07.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

struct UserResponse: Decodable {
    let id: String
    let username: String
    let givenName: String
    let familyName: String
    private let rawNamePrefix: String
    private let rawNameSuffix: String
    private let pictureUrl: URL?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case pictureUrl = "avatar_normal"
    }

    enum NameKeys: String, CodingKey {
        case username
        case givenName = "given"
        case familyName = "family"
        case rawNamePrefix = "prefix"
        case rawNameSuffix = "suffix"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decodeIfPresent(String.self, forKey: .id) ?? container.decode(String.self, forKey: .userId)
        pictureUrl = try container.decodeIfPresent(URL.self, forKey: .pictureUrl)

        let nameContainer = try container.nestedContainer(keyedBy: NameKeys.self, forKey: .name)

        username = try nameContainer.decode(String.self, forKey: .username)
        givenName = try nameContainer.decode(String.self, forKey: .givenName)
        familyName = try nameContainer.decode(String.self, forKey: .familyName)
        rawNamePrefix = try nameContainer.decode(String.self, forKey: .rawNamePrefix)
        rawNameSuffix = try nameContainer.decode(String.self, forKey: .rawNameSuffix)
    }

    init(id: String, username: String = "", givenName: String = "", familyName: String = "", rawNamePrefix: String = "",
         rawNameSuffix: String = "", pictureUrl: URL? = nil) {
        self.id = id
        self.username = username
        self.givenName = givenName
        self.familyName = familyName
        self.rawNamePrefix = rawNamePrefix
        self.rawNameSuffix = rawNameSuffix
        self.pictureUrl = pictureUrl
    }
}

// MARK: - Utilities

extension UserResponse {
    var namePrefix: String? {
        return rawNamePrefix.nilWhenEmpty
    }

    var nameSuffix: String? {
        return rawNameSuffix.nilWhenEmpty
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
