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

    @objc(SignInViewModelErrors)
    public enum Errors: Int, LocalizedError {
        case authorizationFailed
        case invalidConsumerKey

        public var errorDescription: String? {
            switch self {
            case .authorizationFailed:
                return "There was an error authorizing StudApp to access your organization.".localized
            case .invalidConsumerKey:
                return "It seems like your organization does not support StudApp anymore.".localized
            }
        }
    }

    // MARK: - Managing State

    @objc
    public enum State: Int {
        case updatingCredentials, updatingRequestToken, authorizing, updatingAccessToken, signingIn, signedIn
    }

    public let organization: Organization

    @objc public private(set) dynamic var state = State.updatingCredentials

    @objc public private(set) dynamic var authorizationUrl: URL?

    @objc public private(set) dynamic var error: Error?

    // MARK: - Life Cycle

    private let coreDataService = ServiceContainer.default[CoreDataService.self]
    private let storeService = ServiceContainer.default[StoreService.self]
    private let studIpService = ServiceContainer.default[StudIpService.self]
    private var oAuth1: OAuth1<StudIpOAuth1Routes>?

    public init(organization: Organization) {
        self.organization = organization
    }

    // MARK: - Providing Metadata

    public func updateOrganizationIcon() {
        organization.updateIcon(in: coreDataService.viewContext) { _ in
            try? self.coreDataService.viewContext.saveAndWaitWhenChanged()
        }
    }

    // MARK: - Signing In

    public func startAuthorization() {
        updateCredentials()
    }

    public func finishAuthorization(withCallbackUrl url: URL) {
        guard state == .authorizing else { fatalError() }

        state = .updatingAccessToken
        updateAccessToken(withCallbackUrl: url)
    }

    public func retry() {
        switch state {
        case .updatingCredentials:
            updateCredentials()
        case .updatingRequestToken:
            updateRequestToken()
        case .updatingAccessToken:
            guard let url = authorizationUrl else { return startAuthorization() }
            updateAccessToken(withCallbackUrl: url)
        case .signingIn:
            signIn()
        case .authorizing, .signedIn:
            break
        }
    }

    private func updateCredentials() {
        guard state == .updatingCredentials else { fatalError() }

        organization.apiCredentials { result in
            guard let credentials = result.value else {
                return self.error = result.error ?? Errors.invalidConsumerKey
            }

            let oAuth1 = OAuth1<StudIpOAuth1Routes>(callbackUrl: App.Urls.signInCallback,
                                                    consumerKey: credentials.consumerKey, consumerSecret: credentials.consumerSecret)
            oAuth1.baseUrl = self.organization.apiUrl
            self.oAuth1 = oAuth1

            self.state = .updatingRequestToken
            self.updateRequestToken()
        }
    }

    private func updateRequestToken() {
        guard state == .updatingRequestToken, let oAuth1 = oAuth1 else { fatalError() }

        oAuth1.createRequestToken { result in
            guard let url = self.oAuth1?.authorizationUrl else {
                return self.error = result.error ?? Errors.invalidConsumerKey
            }

            self.authorizationUrl = url
            self.state = .authorizing
        }
    }

    private func updateAccessToken(withCallbackUrl url: URL) {
        guard state == .updatingAccessToken, let oAuth1 = oAuth1 else { fatalError() }

        oAuth1.createAccessToken(fromAuthorizationCallbackUrl: url) { result in
            guard result.isSuccess else {
                return self.error = result.error ?? Errors.authorizationFailed
            }

            self.state = .signingIn
            self.signIn()
        }
    }

    private func signIn() {
        guard state == .signingIn, let oAuth1 = oAuth1 else { fatalError() }

        studIpService.sign(into: organization, authorizing: oAuth1) { result in
            guard result.isSuccess else {
                return self.error = result.error ?? Errors.authorizationFailed
            }

            self.state = .signedIn
            self.update()
        }
    }

    private func update() {
        guard !ProcessInfo.processInfo.isLowPowerModeEnabled else { return }

        coreDataService.performBackgroundTask { context in
            self.studIpService.update(in: context) {}
        }
    }
}
