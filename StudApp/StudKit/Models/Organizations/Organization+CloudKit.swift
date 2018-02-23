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

    static var enabledPredicate = NSPredicate(format: "isEnabled == YES")

    private var idPredicate: NSPredicate {
        return NSPredicate(format: "recordID == %@", CKRecordID(recordName: id))
    }

    static func update(in context: NSManagedObjectContext, completion: @escaping ResultHandler<[Organization]>) {
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

            DispatchQueue.main.async {
                completion(result)
            }
        }
        operation.recordFetchedBlock = { record in
            guard let organization = OrganizationRecord(from: record) else { return }
            organizations.append(organization)
        }

        ckDatabase.add(operation)
    }

    static func updateIconThumbnails(in context: NSManagedObjectContext, completion: @escaping ResultHandler<Void>) {
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

            DispatchQueue.main.async {
                organization?.iconThumbnailData = try? Data(contentsOf: iconThumbnailAsset.fileURL)
            }
        }

        ckDatabase.add(operation)
    }

    func updateIcon(in context: NSManagedObjectContext, completion: @escaping ResultHandler<Void>) {
        let query = CKQuery(recordType: OrganizationRecord.recordType, predicate: idPredicate)

        let operation = CKQueryOperation(query: query)
        operation.qualityOfService = .utility
        operation.desiredKeys = [OrganizationRecord.Keys.icon.rawValue]
        operation.queryCompletionBlock = { _, error in
            DispatchQueue.main.async { completion(Result((), error: error)) }
        }
        operation.recordFetchedBlock = { record in
            guard
                let iconThumbnailAsset = record[OrganizationRecord.Keys.icon.rawValue] as? CKAsset,
                let organization = context.object(with: self.objectID) as? Organization
            else { return }

            DispatchQueue.main.async {
                organization.iconData = try? Data(contentsOf: iconThumbnailAsset.fileURL)
            }
        }

        Organization.ckDatabase.add(operation)
    }
}
