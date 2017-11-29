//
//  OrganizationListViewModel.swift
//  StudKit
//
//  Created by Steffen Ryll on 26.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CloudKit

public final class OrganizationListViewModel {
    public enum State {
        case loading
        case success([OrganizationRecord])
        case failure(Error)
    }

    /// Current state of this view model, which should be respected by the user interface.
    public var state: State = .loading {
        didSet {
            DispatchQueue.main.async {
                self.stateChanged?(self.state)
            }
        }
    }

    /// This handler is called every time `state` changes.
    public var stateChanged: ((State) -> Void)?

    public func fetch() {
        state = .loading

        var organizations = [OrganizationRecord]()

        let query = CKQuery(recordType: OrganizationRecord.recordType, predicate: NSPredicate(value: true))

        let operation = CKQueryOperation(query: query)
        operation.qualityOfService = .userInitiated
        operation.queryCompletionBlock = { _, error in
            if let error = error {
                self.state = .failure(error)
            } else {
                self.state = .success(organizations)
            }
        }
        operation.recordFetchedBlock = { record in
            guard let organization = OrganizationRecord(from: record) else { return }
            organizations.append(organization)
        }

        let container = CKContainer(identifier: StudKitServiceProvider.iCloudContainerIdentifier)
        container.database(with: .public).add(operation)
    }
}
