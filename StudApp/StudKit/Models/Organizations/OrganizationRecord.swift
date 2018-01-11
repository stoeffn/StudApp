//
//  OrganizationRecord.swift
//  StudKit
//
//  Created by Steffen Ryll on 26.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CloudKit

public struct OrganizationRecord {
    enum Keys: String {
        case apiUrl, authenticationRealm, consumerKey, consumerSecret, title, iconThumbnail, icon
    }

    public static let recordType: String = "Organization"

    let recordId: CKRecordID

    let apiUrl: URL

    let authenticationRealm: String

    let consumerKey: String

    let consumerSecret: String

    public let title: String

    private let iconUrl: URL?

    public lazy var icon: UIImage? = UIImage(contentsOfFile: iconUrl?.path ?? "")

    private let iconThumbnailUrl: URL

    public lazy var iconThumbnail: UIImage? = UIImage(contentsOfFile: iconThumbnailUrl.path)
}

extension OrganizationRecord {
    init?(from record: CKRecord) {
        guard record.recordType == OrganizationRecord.recordType,
            let apiUrlString = record[Keys.apiUrl.rawValue] as? String,
            let apiUrl = URL(string: apiUrlString),
            let authenticationRealm = record[Keys.authenticationRealm.rawValue] as? String,
            let consumerKey = record[Keys.consumerKey.rawValue] as? String,
            let consumerSecret = record[Keys.consumerSecret.rawValue] as? String,
            let title = record[Keys.title.rawValue] as? String,
            let iconThumbnailAsset = record[Keys.iconThumbnail.rawValue] as? CKAsset
        else { return nil }

        let iconAsset = record[Keys.icon.rawValue] as? CKAsset

        recordId = record.recordID
        self.apiUrl = apiUrl
        self.authenticationRealm = authenticationRealm
        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret
        self.title = title
        iconUrl = iconAsset?.fileURL
        iconThumbnailUrl = iconThumbnailAsset.fileURL
    }
}
