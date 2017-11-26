//
//  OrganizationRecord.swift
//  StudKit
//
//  Created by Steffen Ryll on 26.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CloudKit

public struct OrganizationRecord {
    public static let recordType: String = "Organization"

    public let apiUrl: URL

    public let authenticationRealm: String

    public let title: String
}

extension OrganizationRecord {
    init?(from record: CKRecord) {
        guard record.recordType == OrganizationRecord.recordType,
            let apiUrlString = record["apiUrl"] as? String,
            let apiUrl = URL(string: apiUrlString),
            let authenticationRealm = record["authenticationRealm"] as? String,
            let title = record["title"] as? String else { return nil }

        self.apiUrl = apiUrl
        self.authenticationRealm = authenticationRealm
        self.title = title
    }
}
