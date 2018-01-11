//
//  SignInViewModel.swift
//  StudKit
//
//  Created by Steffen Ryll on 01.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CloudKit

public final class SignInViewModel {
    public enum State {
        case idle

        case loading

        case authorizing

        case failure(Error)

        /// User has been signed in successfully. The view should now show the application's main view.
        case success
    }

    public enum Errors: LocalizedError {

        public var errorDescription: String? {
            fatalError()
        }
    }

    private let coreDataService = ServiceContainer.default[CoreDataService.self]
    private let studIpService = ServiceContainer.default[StudIpService.self]

    public let organization: OrganizationRecord

    /// Current state of the sign-in process, which should be respected by the user interface.
    public var state: State = .idle {
        didSet { stateChanged?(state) }
    }

    /// This handler is called every time `state` changes.
    public var stateChanged: ((State) -> Void)?

    public init(organization: OrganizationRecord) {
        self.organization = organization
    }

    public func authorizationUrl(handler: @escaping ResultHandler<URL>) {
        studIpService.authorizationUrl(for: organization, handler: handler)
    }

    public func organizationIcon(handler: @escaping ResultHandler<UIImage>) {
        let container = CKContainer(identifier: App.iCloudContainerIdentifier)
        container.database(with: .public).fetch(withRecordID: organization.recordId) { record, error in
            DispatchQueue.main.async {
                guard
                    let record = record,
                    var organization = OrganizationRecord(from: record),
                    let icon = organization.icon
                else { return handler(.failure(error)) }

                handler(.success(icon))
            }
        }
    }

    private func updateSemesters() {
        coreDataService.performBackgroundTask { context in
            Semester.update(in: context) { _ in
                try? context.saveWhenChanged()
            }
        }
    }
}
