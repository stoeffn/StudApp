//
//  OrganizationRecord.swift
//  StudKit
//
//  Created by Steffen Ryll on 26.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CloudKit
import CoreData

public struct OrganizationRecord {
    enum Keys: String {
        case apiUrl, consumerKey, consumerSecret, title, iconThumbnail, icon
    }

    public static let recordType: String = "Organization"

    let id: String
    let apiUrl: URL
    let consumerKey: String
    let consumerSecret: String
    let title: String

    init(id: String, apiUrl: URL? = nil, title: String = "", consumerKey: String = "", consumerSecret: String = "") {
        self.id = id
        self.apiUrl = apiUrl ?? URL(string: "localhost")!
        self.title = title
        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret
    }
}

extension OrganizationRecord {
    init?(from record: CKRecord) {
        guard record.recordType == OrganizationRecord.recordType,
            let apiUrlString = record[Keys.apiUrl.rawValue] as? String,
            let apiUrl = URL(string: apiUrlString),
            let consumerKey = record[Keys.consumerKey.rawValue] as? String,
            let consumerSecret = record[Keys.consumerSecret.rawValue] as? String,
            let title = record[Keys.title.rawValue] as? String
        else { return nil }

        id = record.recordID.recordName
        self.apiUrl = apiUrl
        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret
        self.title = title
    }
}

extension OrganizationRecord {
    @discardableResult
    func coreDataObject(in context: NSManagedObjectContext) throws -> Organization {
        let (organization, _) = try Organization.fetch(byId: id, orCreateIn: context)
        organization.title = title
        organization.apiUrl = apiUrl.absoluteString

        let keychainService = ServiceContainer.default[KeychainService.self]
        let service = organization.objectIdentifier.rawValue
        try keychainService.save(password: consumerKey, for: service, account: Keys.consumerKey.rawValue)
        try keychainService.save(password: consumerSecret, for: service, account: Keys.consumerSecret.rawValue)

        return organization
    }
}
