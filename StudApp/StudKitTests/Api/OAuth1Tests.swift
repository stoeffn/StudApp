//
//  OAuth1Tests.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 02.01.18.
//  Copyright © 2018 Steffen Ryll. All rights reserved.
//

import XCTest
@testable import StudKit

final class OAuth1Tests: XCTestCase {
    private let oAuth1 = OAuth1(api: MockApi<StudIpOAuth1Routes>(
        baseUrl: URL(string: "https://www.example.com/")!), consumerKey: "dpf43f3p2l4k3l03", consumerSecret: "kd94hf93k423kf44")

    // MARK: - Coding

    func testDecodeParameter_Nonce() {
        let parameter = oAuth1.decodeParameter(fromRawKeyAndValue: "oauth_nonce=1191242096")
        XCTAssertEqual(parameter?.0, .nonce)
        XCTAssertEqual(parameter?.1, "1191242096")
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

    // MARK: - Signing Requests

    func testSignatureBaseForRequest_Post() {
        var request = URLRequest(url: URL(string: "https://www.example.com/dispatch.php/api/oauth/request_token")!)
        request.httpMethod = "POST"
        let timestamp = Date(timeIntervalSince1970: 1_191_242_096)
        let base = oAuth1.signatureBase(for: request, nonce: "kllo9940pd9333jh", timestamp: timestamp)
        XCTAssertEqual(base, [
            "POST&https%3A%2F%2Fwww.example.com%2Fdispatch.php%2Fapi%2Foauth%2Frequest_token&oauth_consumer_key",
            "%3Ddpf43f3p2l4k3l03%26oauth_nonce%3Dkllo9940pd9333jh%26oauth_signature_method%3DHMAC-SHA1",
            "%26oauth_timestamp%3D1191242096%26oauth_version%3D1.0",
        ].joined())
    }

    func testSignatureBaseForRequest_QueryParameters() {
        var request = URLRequest(url: URL(string: "https://www.example.com/api/kittens?test=abc&something=cool!")!)
        request.httpMethod = "GET"
        let timestamp = Date(timeIntervalSince1970: 1_191_242_096)
        let base = oAuth1.signatureBase(for: request, nonce: "kllo9940pd9333jh", timestamp: timestamp)
        XCTAssertEqual(base, [
            "GET&https%3A%2F%2Fwww.example.com%2Fapi%2Fkittens&oauth_consumer_key%3Ddpf43f3p2l4k3l03%26oauth_nonce",
            "%3Dkllo9940pd9333jh%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1191242096%26oauth_version",
            "%3D1.0%26something%3Dcool%2521%26test%3Dabc",
        ].joined())
    }

    func testSignatureBaseForRequest_EmptyQueryParameters() {
        var request = URLRequest(url: URL(string: "https://www.example.com/api/kittens?empty=")!)
        request.httpMethod = "GET"
        let timestamp = Date(timeIntervalSince1970: 1_191_242_096)
        let base = oAuth1.signatureBase(for: request, nonce: "kllo9940pd9333jh", timestamp: timestamp)
        XCTAssertEqual(base, [
            "GET&https%3A%2F%2Fwww.example.com%2Fapi%2Fkittens&empty%3D%26oauth_consumer_key",
            "%3Ddpf43f3p2l4k3l03%26oauth_nonce%3Dkllo9940pd9333jh%26oauth_signature_method%3D",
            "HMAC-SHA1%26oauth_timestamp%3D1191242096%26oauth_version%3D1.0",
        ].joined())
    }

    func testSignatureBaseForRequest_ArrayQueryParameters() {
        var request = URLRequest(url: URL(string: "https://www.example.com/api/kittens?test=abc&test=def")!)
        request.httpMethod = "GET"
        let timestamp = Date(timeIntervalSince1970: 1_191_242_096)
        let base = oAuth1.signatureBase(for: request, nonce: "kllo9940pd9333jh", timestamp: timestamp)
        XCTAssertEqual(base, [
            "GET&https%3A%2F%2Fwww.example.com%2Fapi%2Fkittens&oauth_consumer_key%3Ddpf43f3p2l4k3l03%26oauth_nonce",
            "%3Dkllo9940pd9333jh%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1191242096%26oauth_version",
            "%3D1.0%26test%3Dabc%26test%3Ddef",
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
