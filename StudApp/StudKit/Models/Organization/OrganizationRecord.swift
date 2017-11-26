//
//  OrganizationRecord.swift
//  StudKit
//
//  Created by Steffen Ryll on 26.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CloudKit

public struct OrganizationRecord: ByTypeNameIdentifiable {
    public let apiUrl: URL

    public let authenticationRealm: String

    public let title: String
}

extension OrganizationRecord {
    init?(from record: CKRecord) {
        guard record.recordType == OrganizationRecord.typeIdentifier,
            let apiUrl = record["apiUrl"] as? URL,
            let authenticationRealm = record["authenticationRealm"] as? String,
            let title = record["title"] as? String else { return nil }

        self.apiUrl = apiUrl
        self.authenticationRealm = authenticationRealm
        self.title = title
    }
}
