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

    let id: String
    let apiUrl: URL
    let title: String

    init(id: String, apiUrl: URL? = nil, title: String = "") {
        self.id = id
        self.apiUrl = apiUrl ?? URL(string: "localhost")!
        self.title = title
    }
}

extension OrganizationRecord {
    init?(from record: CKRecord) {
        guard record.recordType.lowercased() == Organization.recordType,
            let apiUrlString = record[Keys.apiUrl.rawValue] as? String,
            let apiUrl = URL(string: apiUrlString),
            let title = record[Keys.title.rawValue] as? String
        else { return nil }

        id = record.recordID.recordName
        self.apiUrl = apiUrl
        self.title = title
    }
}

extension OrganizationRecord {
    @discardableResult
    func coreDataObject(in context: NSManagedObjectContext) throws -> Organization {
        let (organization, _) = try Organization.fetch(byId: id, orCreateIn: context)
        organization.title = title
        organization.apiUrl = apiUrl
        return organization
    }
}
