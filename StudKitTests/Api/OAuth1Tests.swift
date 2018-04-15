//
//  OAuth1Tests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 02.01.18.
//  Copyright © 2018 Steffen Ryll. All rights reserved.
//

@testable import StudKit
import XCTest

final class OAuth1Tests: XCTestCase {
    private static let serviceName = "test"
    private static let baseUrl = URL(string: "https://www.example.com/")!
    private static let callbackUrl = URL(string: "callback://sign-in")!
    private static let consumerKey = "dpf43f3p2l4k3l03"
    private static let consumerSecret = "kd94hf93k423kf44"
    private static let nonce = "323lvAsQ707p"
    private static let timestamp = Date(timeIntervalSince1970: 1_191_242_096)
    private static let timestampString = "1191242096"
    private static let signatureMethod = "HMAC-SHA1"
    private static let version = "1.0"

    private let oAuth1 = OAuth1(service: serviceName, api: MockApi<StudIpOAuth1Routes>(baseUrl: baseUrl),
                                callbackUrl: callbackUrl, consumerKey: consumerKey, consumerSecret: consumerSecret)

    // MARK: - Coding

    func testDecodeParameter_Nonce() {
        let parameter = oAuth1.decodeParameter(fromRawKeyAndValue: "oauth_nonce=\(OAuth1Tests.nonce)")
        XCTAssertEqual(parameter?.0, .nonce)
        XCTAssertEqual(parameter?.1, OAuth1Tests.nonce)
    }

    func testDecodeParameter_Token() {
        let parameter = oAuth1.decodeParameter(fromRawKeyAndValue: "oauth_token=cool%21")
        XCTAssertEqual(parameter?.0, .token)
        XCTAssertEqual(parameter?.1, "cool!")
    }

    func testDecodeParameters() {
        let data = "oauth_nonce=1191242096&oauth_token=cool%21&oauth_version=42".data(using: .utf8)!
        let parameters = try! oAuth1.decodeParameters(fromResponseData: data)
        XCTAssertEqual(parameters, [
            .nonce: "1191242096",
            .token: "cool!",
            .version: "42",
        ])
    }

    // MARK: - Generating the Authorization Parameters and Header

    func testNormalizedUrl_Normal() {
        let normalizedUrl = oAuth1.normalizedUrl(URL(string: "https://www.example.com/api/kittens")!)
        XCTAssertEqual(normalizedUrl?.absoluteString, "https://www.example.com/api/kittens")
    }

    func testNormalizedUrl_StandardPort() {
        let normalizedUrl = oAuth1.normalizedUrl(URL(string: "https://www.example.com:443/api/kittens")!)
        XCTAssertEqual(normalizedUrl?.absoluteString, "https://www.example.com:443/api/kittens")
    }

    func testNormalizedUrl_NonStandardPort() {
        let normalizedUrl = oAuth1.normalizedUrl(URL(string: "https://www.example.com:42/api/kittens")!)
        XCTAssertEqual(normalizedUrl?.absoluteString, "https://www.example.com:42/api/kittens")
    }

    func testNormalizedUrl_QueryParameters() {
        let normalizedUrl = oAuth1.normalizedUrl(URL(string: "https://www.example.com/api/kittens?test=abc&test=def")!)
        XCTAssertEqual(normalizedUrl?.absoluteString, "https://www.example.com/api/kittens")
    }

    func testAuthorizationParametersForRequest() {
        var request = URLRequest(url: URL(string: "https://www.example.com/dispatch.php/api/oauth/request_token")!)
        request.httpMethod = "POST"
        let parameters = oAuth1.authorizationParameters(for: request, nonce: OAuth1Tests.nonce, timestamp: OAuth1Tests.timestamp)

        XCTAssertEqual(parameters[.callback] ?? "", OAuth1Tests.callbackUrl.absoluteString)
        XCTAssertEqual(parameters[.consumerKey] ?? "", OAuth1Tests.consumerKey)
        XCTAssertEqual(parameters[.nonce] ?? "", OAuth1Tests.nonce)
        XCTAssertEqual(parameters[.signature] ?? "", "wyx%2F7ZwCaexJOkeMsRX%2FV50bri4%3D")
        XCTAssertEqual(parameters[.signatureMethod] ?? "", OAuth1Tests.signatureMethod)
        XCTAssertEqual(parameters[.timestamp] ?? "", OAuth1Tests.timestampString)
        XCTAssertEqual(parameters[.version] ?? "", OAuth1Tests.version)
    }

    func testAuthorizationHeaderForRequest() {
        var request = URLRequest(url: URL(string: "https://www.example.com/dispatch.php/api/oauth/request_token")!)
        request.httpMethod = "POST"
        let header = oAuth1.authorizationHeader(for: request)

        XCTAssertTrue(header.starts(with: "OAuth oauth_callback="), header)
        XCTAssertTrue(header.contains("oauth_signature="), header)
    }

    // MARK: - Signing Requests

    func testSignatureBaseForRequest_Post() {
        var request = URLRequest(url: URL(string: "https://www.example.com/dispatch.php/api/oauth/request_token")!)
        request.httpMethod = "POST"
        let base = oAuth1.signatureBase(for: request, nonce: OAuth1Tests.nonce, timestamp: OAuth1Tests.timestamp)

        XCTAssertEqual(base, [
            "POST&https%3A%2F%2Fwww.example.com%2Fdispatch.php%2Fapi%2Foauth%2Frequest_token",
            "&oauth_callback%3Dcallback%253A%252F%252Fsign-in%26oauth_consumer_key%3Ddpf43f3p2l4k3l03%26",
            "oauth_nonce%3D323lvAsQ707p%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp",
            "%3D1191242096%26oauth_token%3D%26oauth_verifier%3D%26oauth_version%3D1.0",
        ].joined())
    }

    func testSignatureBaseForRequest_QueryParameters() {
        var request = URLRequest(url: URL(string: "https://www.example.com/api/kittens?test=abc&something=cool!")!)
        request.httpMethod = "GET"
        let base = oAuth1.signatureBase(for: request, nonce: OAuth1Tests.nonce, timestamp: OAuth1Tests.timestamp)

        XCTAssertEqual(base, [
            "GET&https%3A%2F%2Fwww.example.com%2Fapi%2Fkittens&oauth_callback%3Dcallback%253A%252F%252Fsign-in%26",
            "oauth_consumer_key%3Ddpf43f3p2l4k3l03%26oauth_nonce%3D323lvAsQ707p%26oauth_signature_method%3DHMAC-SHA1",
            "%26oauth_timestamp%3D1191242096%26oauth_token%3D%26oauth_verifier%3D%26oauth_version%3D1.0%26something",
            "%3Dcool%2521%26test%3Dabc",
        ].joined())
    }

    func testSignatureBaseForRequest_EmptyQueryParameters() {
        var request = URLRequest(url: URL(string: "https://www.example.com/api/kittens?empty=")!)
        request.httpMethod = "GET"
        let base = oAuth1.signatureBase(for: request, nonce: OAuth1Tests.nonce, timestamp: OAuth1Tests.timestamp)

        XCTAssertEqual(base, [
            "GET&https%3A%2F%2Fwww.example.com%2Fapi%2Fkittens&empty%3D%26oauth_callback%3Dcallback%253A%252F%252Fsign-in%26",
            "oauth_consumer_key%3Ddpf43f3p2l4k3l03%26oauth_nonce%3D323lvAsQ707p%26oauth_signature_method%3DHMAC-SHA1%26",
            "oauth_timestamp%3D1191242096%26oauth_token%3D%26oauth_verifier%3D%26oauth_version%3D1.0",
        ].joined())
    }

    func testSignatureBaseForRequest_ArrayQueryParameters() {
        var request = URLRequest(url: URL(string: "https://www.example.com/api/kittens?test=abc&test=def")!)
        request.httpMethod = "GET"
        let base = oAuth1.signatureBase(for: request, nonce: OAuth1Tests.nonce, timestamp: OAuth1Tests.timestamp)

        XCTAssertEqual(base, [
            "GET&https%3A%2F%2Fwww.example.com%2Fapi%2Fkittens&oauth_callback%3Dcallback%253A%252F%252Fsign-in%26",
            "oauth_consumer_key%3Ddpf43f3p2l4k3l03%26oauth_nonce%3D323lvAsQ707p%26oauth_signature_method%3DHMAC-SHA1%26",
            "oauth_timestamp%3D1191242096%26oauth_token%3D%26oauth_verifier%3D%26oauth_version%3D1.0%26test%3Dabc%26test%3Ddef",
        ].joined())
    }

    func testSignatureForMessage_Request() {
        let message = [
            "GET&http%3A%2F%2Fphotos.example.net%2Fphotos&file%3Dvacation.jpg%26oauth_consumer_key%3Ddpf43f3p2l4k3l03%26",
            "oauth_nonce%3Dkllo9940pd9333jh%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1191242096%26",
            "oauth_token%3Dnnch734d00sl2jdk%26oauth_version%3D1.0%26size%3Doriginal&kd94hf93k423kf44&pfkkdhi9sl3r4s00",
        ].joined()
        let signature = oAuth1.signature(for: message, key: "kd94hf93k423kf44&pfkkdhi9sl3r4s00")
        XCTAssertEqual(signature, "Gcg/323lvAsQ707p+y41y14qWfY=")
    }

    func testSignatureForMessage_Simple() {
        let signature = oAuth1.signature(for: "simon says", key: "abcedfg123456789")
        XCTAssertEqual(signature, "vyeIZc3+tF6F3i95IEV+AJCWBYQ=")
    }
}
