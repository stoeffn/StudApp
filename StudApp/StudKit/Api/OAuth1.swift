//
//  OAuth1.swift
//  StudKit
//
//  Created by Steffen Ryll on 31.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import Foundation
import CommonCrypto

final class OAuth1<Routes: OAuth1Routes>: ApiAuthorizing {
    private let version = "1.0"
    private let signatureMethod = "HMAC-SHA1"
    private let api: Api<Routes>
    private let consumerKey: String
    private let consumerSecret: String
    private var token: String?
    private var tokenSecret: String?
    private var isAuthorized = false

    // MARK: - Errors

    enum Errors: Error {
        case test
    }

    // MARK: - Life Cycle

    init(api: Api<Routes> = Api<Routes>(), consumerKey: String, consumerSecret: String) {
        self.api = api
        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret

        api.authorizing = self
    }

    // MARK: - Coding

    enum CodingKeys: String, CodingKey {
        case consumerKey = "oauth_consumer_key"
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
        guard let response = String(data: data, encoding: .utf8) else { throw Errors.test }
        let keysAndValues = response
            .split(separator: "&")
            .map(String.init)
            .flatMap(decodeParameter)
        return Dictionary(uniqueKeysWithValues: keysAndValues)
    }

    // MARK: -

    var authorizationUrl: URL? {
        let parameters = [URLQueryItem(name: CodingKeys.token.rawValue, value: token)]
        return api.url(for: .authorize, parameters: parameters)
    }

    func createRequestToken(handler: @escaping ResultHandler<Void>) {
        api.request(.requestToken) { self.handleResponse(result: $0, handler: handler) }
    }

    func createAccessToken(verifier _: String, handler: @escaping ResultHandler<Void>) {
        api.request(.accessToken) { self.handleResponse(result: $0, handler: handler) }
    }

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

    func nonce() -> String {
        return UUID().uuidString
    }

    func normalizedUrl(_ url: URL) -> URL? {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        components.queryItems = nil
        components.fragment = nil
        return components.url
    }

    func authorizationParameters(nonce: String, timestamp: Date) -> [CodingKeys: String] {
        return [
            .consumerKey: consumerKey,
            .nonce: nonce,
            .signatureMethod: signatureMethod,
            .timestamp: String(Int(timestamp.timeIntervalSince1970)),
            .version: version,
        ]
    }

    func authorizationParameters(for request: URLRequest, nonce: String, timestamp: Date) -> [CodingKeys: String] {
        var parameters = authorizationParameters(nonce: nonce, timestamp: timestamp)
        parameters[.signature] = signature(for: request, key: signingKey, nonce: nonce, timestamp: timestamp) ?? ""
        return parameters
    }

    func authorizationHeader(for request: URLRequest) -> String {
        let parameters = authorizationParameters(for: request, nonce: nonce(), timestamp: Date())
            .sorted { $0.key.rawValue > $1.key.rawValue }
            .map { "\($0.key)=\"\($0.value)\"" }
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

    func signature(for message: String, key: String) -> String? {
        guard
            let messageData = message.data(using: .utf8),
            let keyData = key.data(using: .utf8)
        else { return nil }
        return signature(for: messageData, key: keyData).base64EncodedString()
    }
}
