//
//  SignInViewModel.swift
//  StudKit
//
//  Created by Steffen Ryll on 01.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CloudKit

public final class SignInViewModel: NSObject {

    // MARK: - Errors

    @objc
    public enum Errors: Int, LocalizedError {
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

    // MARK: - Managing State

    @objc
    public enum State: Int {
        case updatingRequestToken, authorizing, updatingAccessToken, signedIn
    }

    public let organization: Organization

    @objc public private(set) dynamic var state = State.updatingRequestToken

    @objc public private(set) dynamic var authorizationUrl: URL?

    @objc public private(set) dynamic var error: Error?

    // MARK: - Life Cycle

    private let coreDataService = ServiceContainer.default[CoreDataService.self]
    private let storeService = ServiceContainer.default[StoreService.self]
    private let studIpService = ServiceContainer.default[StudIpService.self]
    private let oAuth1: OAuth1<StudIpOAuth1Routes>

    public init(organization: Organization) {
        self.organization = organization

        guard let key = organization.consumerKey, let secret = organization.consumerSecret else { fatalError() }
        oAuth1 = OAuth1<StudIpOAuth1Routes>(callbackUrl: App.Links.signInCallback, consumerKey: key, consumerSecret: secret)
        oAuth1.baseUrl = organization.apiUrl
    }

    // MARK: - Providing Metadata

    public func updateOrganizationIcon() {
        organization.updateIcon(in: coreDataService.viewContext) { _ in
            try? self.coreDataService.viewContext.saveAndWaitWhenChanged()
        }
    }

    // MARK: - Signing In

    public func startAuthorization() {
        state = .updatingRequestToken

        try? oAuth1.createRequestToken { result in
            guard let url = self.oAuth1.authorizationUrl else {
                return self.error = result.error ?? Errors.invalidConsumerKey
            }

            self.authorizationUrl = url
            self.state = .authorizing
        }
    }

    public func retry() {
        switch state {
        case .updatingRequestToken:
            startAuthorization()
        case .updatingAccessToken:
            guard let url = authorizationUrl else { return startAuthorization() }
            finishAuthorization(withCallbackUrl: url)
        default:
            break
        }
    }

    public func finishAuthorization(withCallbackUrl url: URL) {
        state = .updatingAccessToken

        try? oAuth1.createAccessToken(fromAuthorizationCallbackUrl: url) { result in
            guard result.isSuccess else {
                return self.error = result.error ?? Errors.authorizationFailed
            }

            self.studIpService.sign(into: self.organization, authorizing: self.oAuth1) { result in
                guard result.isSuccess else {
                    return self.error = result.error ?? Errors.authorizationFailed
                }

                self.state = .signedIn
                self.updateSemesters()
            }
        }
    }

    private func updateSemesters() {
        coreDataService.performBackgroundTask { context in
            self.organization.updateSemesters(in: context) { _ in
                try? context.saveAndWaitWhenChanged()
            }
        }
    }
}
