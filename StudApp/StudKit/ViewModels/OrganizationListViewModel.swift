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
        case failure(String)
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
            switch error {
            case nil:
                self.state = .success(organizations)
            case CKError.networkUnavailable?, CKError.networkUnavailable?:
                self.state = .failure("There seems to be a problem with the internet connection.")
            default:
                self.state = .failure("Unfortunately, there was an internal error.")
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
