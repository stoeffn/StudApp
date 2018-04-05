//
//  StudApp—Stud.IP to Go
//  Copyright © 2018, Steffen Ryll
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see http://www.gnu.org/licenses/.
//

import Swifter

public final class SignInViewModel: NSObject {

    // MARK: - Errors

    @objc(SignInViewModelErrors)
    public enum Errors: Int, LocalizedError {
        case authorizationFailed, invalidConsumerKey, invalidCallback

        public var errorDescription: String? {
            switch self {
            case .authorizationFailed:
                return "There was an error authorizing StudApp to access your organization.".localized
            case .invalidConsumerKey:
                return "It seems like your organization does not support StudApp anymore.".localized
            case .invalidCallback:
                return "Invalid Server Callback.".localized
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

    deinit {
        server.stop()
    }

    // MARK: - Providing Metadata

    public func updateOrganizationIcon() {
        organization.updateIcon(in: coreDataService.viewContext) { _ in
            try? self.coreDataService.viewContext.saveAndWaitWhenChanged()
        }
    }

    // MARK: - Callback Server

    private lazy var server: HttpServer = {
        let server = HttpServer()
        server["/sign-in"] = { [weak self] request in
            guard self?.state == .authorizing else { fatalError() }

            guard !request.queryParams.isEmpty else {
                return .movedPermanently("\(App.scheme)://\(request.path)")
            }

            DispatchQueue.main.async {
                if let url = URL(string: request.path) {
                    self?.state = .updatingAccessToken
                    self?.updateAccessToken(withCallbackUrl: url)
                } else {
                    self?.error = Errors.invalidCallback
                }
            }

            return .ok(.text(""))
        }
        return server
    }()

    // MARK: - Signing In

    public func startAuthorization() {
        updateCredentials()
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

            do {
                try self.server.start()
                self.authorizationUrl = url
                self.state = .authorizing
            } catch {
                self.error = error
            }
        }
    }

    private func updateAccessToken(withCallbackUrl url: URL) {
        guard state == .updatingAccessToken, let oAuth1 = oAuth1 else { fatalError() }

        server.stop()
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
