//
//  OAuth1.swift
//  StudKit
//
//  Created by Steffen Ryll on 31.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import Foundation
import CommonCrypto

/// Provides the ability to authorize against an API that utilizes OAuth 1.0.
///
/// - Remark: For reference, see the [official RFC](https://tools.ietf.org/html/rfc5849#section-3.3) and
///           [Authentication Sandbox](http://lti.tools/oauth/).
final class OAuth1<Routes: OAuth1Routes>: ApiAuthorizing {
    private let version = "1.0"
    private let signatureMethod = "HMAC-SHA1"
    private let api: Api<Routes>
    private let callbackUrl: URL?
    private let consumerKey: String
    private let consumerSecret: String
    private var token: String?
    private var tokenSecret: String?
    private var verifier: String?

    let service: String

    private(set) var isAuthorized: Bool

    // MARK: - Life Cycle

    init(service: String, api: Api<Routes>? = nil, callbackUrl: URL? = nil, consumerKey: String, consumerSecret: String,
         token: String? = nil, tokenSecret: String? = nil, isAuthorized: Bool = false) {
        self.service = service
        self.api = api ?? Api<Routes>()
        self.callbackUrl = callbackUrl
        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret
        self.token = token
        self.tokenSecret = tokenSecret
        self.isAuthorized = isAuthorized

        self.api.authorizing = self
    }

    var baseUrl: URL? {
        get { return api.baseUrl }
        set { api.baseUrl = newValue }
    }

    // MARK: - Coding

    enum CodingKeys: String, CodingKey {
        case callback = "oauth_callback"
        case consumerKey = "oauth_consumer_key"
        case consumerSecret = "oauth_consumer_secret"
        case nonce = "oauth_nonce"
        case signatureMethod = "oauth_signature_method"
        case signature = "oauth_signature"
        case timestamp = "oauth_timestamp"
        case token = "oauth_token"
        case tokenSecret = "oauth_token_secret"
        case verifier = "oauth_verifier"
        case version = "oauth_version"
    }

    func decodeParameter(fromRawKeyAndValue rawKeyAndValue: String) -> (CodingKeys, String)? {
        let keyAndValue = rawKeyAndValue.split(separator: "=", maxSplits: 1)
        guard
            let rawKey = keyAndValue.first,
            let value = keyAndValue.last?.removingPercentEncoding,
            let key = CodingKeys(rawValue: String(rawKey))
        else { return nil }
        return (key, String(value))
    }

    func decodeParameters(fromResponseData data: Data) throws -> [CodingKeys: String] {
        guard let response = String(data: data, encoding: .utf8) else {
            let context = DecodingError.Context(codingPath: [], debugDescription: "Data could not be converted to string.")
            throw DecodingError.dataCorrupted(context)
        }
        let keysAndValues = response
            .split(separator: "&")
            .map(String.init)
            .flatMap(decodeParameter)
        return Dictionary(uniqueKeysWithValues: keysAndValues)
    }

    func decodeVerifier(fromAuthorizationCallbackUrl url: URL) -> String? {
        return URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?
            .first { $0.name == CodingKeys.verifier.rawValue }?
            .value
    }

    // MARK: - Making Authorization Requests

    /// URL to open in a web browser for requesting a user's permission to access protected resources.
    ///
    /// - Remark: You must first create a request token.
    var authorizationUrl: URL? {
        let parameters = [URLQueryItem(name: CodingKeys.token.rawValue, value: token)]
        return api.url(for: .authorize, parameters: parameters)
    }

    /// Creates a request token that can be used for asking a user for permissions.
    func createRequestToken(handler: @escaping ResultHandler<Void>) {
        api.request(.requestToken) { self.handleResponse(result: $0, handler: handler) }
    }

    func createAccessToken(fromAuthorizationCallbackUrl url: URL, handler: @escaping ResultHandler<Void>) {
        guard let verifier = decodeVerifier(fromAuthorizationCallbackUrl: url) else {
            let context = DecodingError.Context(codingPath: [CodingKeys.verifier], debugDescription: "")
            let error = DecodingError.keyNotFound(CodingKeys.verifier, context)
            return handler(.failure(error))
        }
        self.verifier = verifier

        api.request(.accessToken) { result in
            self.isAuthorized = result.isSuccess
            self.handleResponse(result: result, handler: handler)
        }
    }

    /// Tries to decode the result data as OAuth parameters and updates `token` and `tokenSecret` accordingly.
    private func handleResponse(result: Result<Data>, handler: @escaping ResultHandler<Void>) {
        guard let data = result.value else { return handler(.failure(result.error)) }
        do {
            let parameters = try decodeParameters(fromResponseData: data)
            token = parameters[.token]
            tokenSecret = parameters[.tokenSecret]
            handler(.success(()))
        } catch {
            handler(.failure(error))
        }
    }

    // MARK: - Generating the Authorization Parameters and Header

    /// Creates a random nonce for the OAuth process.
    func nonce() -> String {
        return UUID().uuidString
    }

    /// Normalizes `url` for request signing by removing default ports, query parameters, and fragments.
    func normalizedUrl(_ url: URL) -> URL? {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        components.queryItems = nil
        components.fragment = nil
        return components.url
    }

    /// Authorization parameters with the specified `nonce` and `timestamp`. Does not include a signature.
    func authorizationParameters(nonce: String, timestamp: Date) -> [CodingKeys: String?] {
        return [
            .callback: callbackUrl?.absoluteString,
            .consumerKey: consumerKey,
            .nonce: nonce,
            .signatureMethod: signatureMethod,
            .timestamp: String(Int(timestamp.timeIntervalSince1970)),
            .token: token,
            .verifier: verifier,
            .version: version,
        ]
    }

    /// Authorization parameters for a request and a given `nonce` and `timestamp`, including a signature.
    func authorizationParameters(for request: URLRequest, nonce: String, timestamp: Date) -> [CodingKeys: String?] {
        var parameters = authorizationParameters(nonce: nonce, timestamp: timestamp)
        parameters[.signature] = signature(for: request, key: signingKey, nonce: nonce, timestamp: timestamp) ?? ""
        return parameters
    }

    func authorizationHeader(for request: URLRequest) -> String {
        let parameters = authorizationParameters(for: request, nonce: nonce(), timestamp: Date())
            .sorted { $0.key.rawValue < $1.key.rawValue }
            .map { "\($0.key.rawValue)=\"\($0.value ?? "")\"" }
            .joined(separator: ", ")
        return "OAuth \(parameters)"
    }

    // MARK: - Signing Requests

    private let allowedSignatureEncodingCharacters: CharacterSet = {
        var set = CharacterSet(charactersIn: "-_.~")
        set.formUnion(.uppercaseLetters)
        set.formUnion(.lowercaseLetters)
        set.formUnion(.decimalDigits)
        return set
    }()

    private var signingKey: String {
        return "\(consumerSecret)&\(tokenSecret ?? "")"
    }

    func signature(for request: URLRequest, key: String, nonce: String, timestamp: Date) -> String? {
        guard let base = signatureBase(for: request, nonce: nonce, timestamp: timestamp) else { return nil }
        return signature(for: base, key: key)?
            .addingPercentEncoding(withAllowedCharacters: allowedSignatureEncodingCharacters)
    }

    func signatureBase(for request: URLRequest, nonce: String, timestamp: Date) -> String? {
        guard
            let url = request.url,
            let normalizedUrl = normalizedUrl(url),
            let httpMethod = request.httpMethod,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else { return nil }

        let authorizationParameters = self.authorizationParameters(nonce: nonce, timestamp: timestamp)
            .map { URLQueryItem(name: $0.key.rawValue, value: $0.value) }
        let parameters = authorizationParameters + (components.queryItems ?? [])

        let encodedParameters = parameters
            .sorted {
                guard $0.name != $1.name else {
                    return $0.value ?? "" < $1.value ?? ""
                }
                return $0.name < $1.name
            }
            .map { parameter in
                let value = parameter.value?.addingPercentEncoding(withAllowedCharacters: allowedSignatureEncodingCharacters)
                return "\(parameter.name)=\(value ?? "")"
            }
            .joined(separator: "&")

        return [httpMethod, normalizedUrl.absoluteString, encodedParameters]
            .flatMap { $0.addingPercentEncoding(withAllowedCharacters: allowedSignatureEncodingCharacters) }
            .joined(separator: "&")
    }

    /// Returns the HMAC-SHA1 signature for `data`, signed by `key`.
    func signature(for data: Data, key: Data) -> Data {
        let signature = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: Int(CC_SHA1_DIGEST_LENGTH))
        defer { signature.deallocate(capacity: Int(CC_SHA1_DIGEST_LENGTH)) }

        data.withUnsafeBytes { dataBytes in
            key.withUnsafeBytes { keyBytes in
                CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1), keyBytes, key.count, dataBytes, data.count, signature)
            }
        }

        return Data(bytes: signature, count: Int(CC_SHA1_DIGEST_LENGTH))
    }

    /// Returns the HMAC-SHA1 signature for `message`, signed by `key` and encoded as a base64-string.
    func signature(for message: String, key: String) -> String? {
        guard
            let messageData = message.data(using: .utf8),
            let keyData = key.data(using: .utf8)
        else { return nil }
        return signature(for: messageData, key: keyData).base64EncodedString()
    }
}

// MARK: - Persisting

extension OAuth1: PersistableApiAuthorizing {
    convenience init(fromPersistedService service: String) throws {
        let consumerKey = try KeychainPasswordItem(service: service, account: CodingKeys.consumerKey.rawValue).readPassword()
        let consumerSecret = try KeychainPasswordItem(service: service, account: CodingKeys.consumerSecret.rawValue).readPassword()
        let token = try KeychainPasswordItem(service: service, account: CodingKeys.token.rawValue).readPassword()
        let tokenSecret = try KeychainPasswordItem(service: service, account: CodingKeys.tokenSecret.rawValue).readPassword()

        self.init(service: service, consumerKey: consumerKey, consumerSecret: consumerSecret, token: token,
                  tokenSecret: tokenSecret, isAuthorized: true)
    }

    func persistCredentials() throws {
        guard
            isAuthorized,
            let token = token,
            let tokenSecret = tokenSecret
        else {
            return
        }

        try KeychainPasswordItem(service: service, account: CodingKeys.consumerKey.rawValue).save(password: consumerKey)
        try KeychainPasswordItem(service: service, account: CodingKeys.consumerSecret.rawValue).save(password: consumerSecret)
        try KeychainPasswordItem(service: service, account: CodingKeys.token.rawValue).save(password: token)
        try KeychainPasswordItem(service: service, account: CodingKeys.tokenSecret.rawValue).save(password: tokenSecret)
    }

    func removeCredentials() throws {
        try KeychainPasswordItem(service: service, account: CodingKeys.consumerKey.rawValue).delete()
        try KeychainPasswordItem(service: service, account: CodingKeys.consumerSecret.rawValue).delete()
        try KeychainPasswordItem(service: service, account: CodingKeys.token.rawValue).delete()
        try KeychainPasswordItem(service: service, account: CodingKeys.tokenSecret.rawValue).delete()
    }
}
