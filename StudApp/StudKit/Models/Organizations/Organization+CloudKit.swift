//
//  Organization+CloudKit.swift
//  StudKit
//
//  Created by Steffen Ryll on 22.02.18.
//  Copyright © 2018 Steffen Ryll. All rights reserved.
//

import CloudKit
import CoreData

extension Organization {
    private static var ckDatabase: CKDatabase = CKContainer(identifier: App.iCloudContainerIdentifier).database(with: .public)

    private static var enabledPredicate = NSPredicate(format: "isEnabled == YES")

    public static func update(in context: NSManagedObjectContext, completion: @escaping ResultHandler<[Organization]>) {
        var organizations = [OrganizationRecord]()

        let query = CKQuery(recordType: OrganizationRecord.recordType, predicate: Organization.enabledPredicate)
        let desiredKeys: [OrganizationRecord.Keys] = [.apiUrl, .title, .consumerKey, .consumerSecret]

        let operation = CKQueryOperation(query: query)
        operation.qualityOfService = .userInitiated
        operation.desiredKeys = desiredKeys.map { $0.rawValue }
        operation.queryCompletionBlock = { _, error in
            let result = Result(organizations, error: error).map {
                try Organization.update(fetchRequest(), with: $0, in: context) { try $0.coreDataObject(in: context) }
            }
            DispatchQueue.main.async { completion(result) }
        }
        operation.recordFetchedBlock = { record in
            guard let organization = OrganizationRecord(from: record) else { return }
            organizations.append(organization)
        }

        ckDatabase.add(operation)
    }

    public static func updateIconThumbnails(in context: NSManagedObjectContext, completion: @escaping ResultHandler<Void>) {
        let query = CKQuery(recordType: OrganizationRecord.recordType, predicate: Organization.enabledPredicate)

        let operation = CKQueryOperation(query: query)
        operation.qualityOfService = .utility
        operation.desiredKeys = [OrganizationRecord.Keys.iconThumbnail.rawValue]
        operation.queryCompletionBlock = { _, error in
            DispatchQueue.main.async { completion(Result((), error: error)) }
        }
        operation.recordFetchedBlock = { record in
            guard
                let iconThumbnailAsset = record[OrganizationRecord.Keys.iconThumbnail.rawValue] as? CKAsset,
                let organization = try? Organization.fetch(byId: record.recordID.recordName, in: context)
            else { return }
            organization?.iconThumbnailData = try? Data(contentsOf: iconThumbnailAsset.fileURL)
        }

        ckDatabase.add(operation)
    }
}
