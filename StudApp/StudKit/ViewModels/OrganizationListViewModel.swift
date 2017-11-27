//
//  OrganizationListViewModel.swift
//  StudKit
//
//  Created by Steffen Ryll on 26.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CloudKit

public final class OrganizationListViewModel {
    private var organizations = [OrganizationRecord]()

    public weak var delegate: DataSourceSectionDelegate?

    public func fetch(handler: @escaping ResultHandler<[OrganizationRecord]> = { _ in }) {
        let query = CKQuery(recordType: OrganizationRecord.recordType, predicate: NSPredicate(value: true))

        let operation = CKQueryOperation(query: query)
        operation.qualityOfService = .userInitiated
        operation.queryCompletionBlock = { (_, error) in
            let result = Result(self.organizations, error: error)

            DispatchQueue.main.async {
                self.delegate?.dataDidChange(in: self)
                handler(result)
            }
        }
        operation.recordFetchedBlock = { record in
            guard let organization = OrganizationRecord(from: record) else { return }
            self.organizations.append(organization)

            DispatchQueue.main.async {
                self.delegate?.data(changedIn: organization, at: self.organizations.endIndex - 1, change: .insert, in: self)
            }
        }

        let container = CKContainer(identifier: StudKitServiceProvider.iCloudContainerIdentifier)
        container.database(with: .public).add(operation)

        delegate?.dataWillChange(in: self)
    }
}

// MARK: - Data Source Section

extension OrganizationListViewModel: DataSourceSection {
    public typealias Row = OrganizationRecord

    public var numberOfRows: Int {
        return organizations.count
    }

    public subscript(rowAt index: Int) -> OrganizationRecord {
        return organizations[index]
    }
}
