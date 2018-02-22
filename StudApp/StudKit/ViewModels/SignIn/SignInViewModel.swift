//
//  SignInViewModel.swift
//  StudKit
//
//  Created by Steffen Ryll on 01.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CloudKit

public final class SignInViewModel {
    public enum Errors: LocalizedError {
        case invalidConsumerKey
        case authorizationFailed

        public var errorDescription: String? {
            switch self {
            case .invalidConsumerKey:
                return "It seems like your organization does not support StudApp anymore.".localized
            case .authorizationFailed:
                return "There was an error authorizing StudApp to access your organization.".localized
            }
        }
    }

    private let coreDataService = ServiceContainer.default[CoreDataService.self]
    private let storeService = ServiceContainer.default[StoreService.self]
    private let studIpService = ServiceContainer.default[StudIpService.self]
    private let oAuth1: OAuth1<StudIpOAuth1Routes>

    public let organization: OrganizationRecord

    // MARK: - Life Cycle

    public init(organization: OrganizationRecord) {
        self.organization = organization

        oAuth1 = OAuth1<StudIpOAuth1Routes>(service: StudIpService.serviceName, callbackUrl: App.Links.signInCallback,
                                            consumerKey: organization.consumerKey, consumerSecret: organization.consumerSecret)
        oAuth1.baseUrl = organization.apiUrl
    }

    // MARK: - Providing Metadata

    public func organizationIcon(completion: @escaping ResultHandler<UIImage>) {
        let container = CKContainer(identifier: App.iCloudContainerIdentifier)
        container.database(with: .public).fetch(withRecordID: organization.recordId) { record, error in
            DispatchQueue.main.async {
                guard
                    let record = record,
                    var organization = OrganizationRecord(from: record),
                    let icon = organization.icon
                else { return completion(.failure(error)) }

                completion(.success(icon))
            }
        }
    }

    // MARK: - Signing In

    public func authorizationUrl(completion: @escaping ResultHandler<URL>) {
        try? oAuth1.createRequestToken { result in
            guard result.isSuccess else {
                return completion(.failure(result.error ?? Errors.invalidConsumerKey))
            }

            completion(result.compactMap { _ in self.oAuth1.authorizationUrl })
        }
    }

    public func handleAuthorizationCallback(url: URL, completion: @escaping ResultHandler<Void>) {
        try? oAuth1.createAccessToken(fromAuthorizationCallbackUrl: url) { result in
            guard result.isSuccess else {
                return completion(.failure(result.error ?? Errors.authorizationFailed))
            }

            self.studIpService.signIn(apiUrl: self.organization.apiUrl, authorizing: self.oAuth1) { result in
                self.updateSemesters()
                completion(result.map { _ in () })
            }
        }
    }

    private func updateSemesters() {
        coreDataService.performBackgroundTask { context in
            Semester.update(in: context) { _ in
                try? context.saveAndWaitWhenChanged()
            }
        }
    }

    public var isAppUnlocked: Bool {
        return storeService.state.isUnlocked
    }

    public var isStoreStateVerified: Bool {
        return storeService.state.isVerifiedByServer
    }
}
