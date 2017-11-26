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
        let database = CKContainer(identifier: "iCloud.SteffenRyll.StudKit").database(with: .public)
        let query = CKQuery(recordType: OrganizationRecord.recordType, predicate: NSPredicate(value: true))

        database.perform(query, inZoneWith: nil) { (records, error) in
            if let records = records {
                self.organizations = records.flatMap { OrganizationRecord(from: $0) }
            }

            DispatchQueue.main.async {
                handler(Result(self.organizations, error: error))
            }
        }
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
