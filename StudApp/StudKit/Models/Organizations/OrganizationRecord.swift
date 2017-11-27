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

    let apiUrl: URL

    let authenticationRealm: String

    public let title: String

    private let iconUrl: URL?

    public lazy var icon: UIImage? = UIImage(contentsOfFile: iconUrl?.path ?? "")

    private let iconThumbnailUrl: URL

    public lazy var iconThumbnail: UIImage? = UIImage(contentsOfFile: iconThumbnailUrl.path)
}

extension OrganizationRecord {
    init?(from record: CKRecord) {
        guard record.recordType == OrganizationRecord.recordType,
            let apiUrlString = record["apiUrl"] as? String,
            let apiUrl = URL(string: apiUrlString),
            let authenticationRealm = record["authenticationRealm"] as? String,
            let title = record["title"] as? String,
            let iconThumbnailAsset = record["iconThumbnail"] as? CKAsset else { return nil }
        let iconAsset = record["icon"] as? CKAsset

        self.apiUrl = apiUrl
        self.authenticationRealm = authenticationRealm
        self.title = title
        iconUrl = iconAsset?.fileURL
        iconThumbnailUrl = iconThumbnailAsset.fileURL
    }
}
