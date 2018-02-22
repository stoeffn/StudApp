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
    public static func update(in context: NSManagedObjectContext, completion: @escaping ResultHandler<[Organization]>) {
        var organizations = [OrganizationRecord]()

        let predicate = NSPredicate(format: "isEnabled == YES")
        let query = CKQuery(recordType: OrganizationRecord.recordType, predicate: predicate)
        let desiredKeys: [OrganizationRecord.Keys] = [.apiUrl, .title, .consumerKey, .consumerSecret]

        let operation = CKQueryOperation(query: query)
        operation.qualityOfService = .userInitiated
        operation.desiredKeys = desiredKeys.map { $0.rawValue }
        operation.queryCompletionBlock = { _, error in
            let result = Result(organizations, error: error).map {
                try Organization.update(fetchRequest(), with: $0, in: context) { try $0.coreDataObject(in: context) }
            }
            completion(result)
        }
        operation.recordFetchedBlock = { record in
            guard let organization = OrganizationRecord(from: record) else { return }
            organizations.append(organization)
        }

        let container = CKContainer(identifier: App.iCloudContainerIdentifier)
        container.database(with: .public).add(operation)
    }
}
