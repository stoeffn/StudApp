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
        baseUrl: URL(string: "https://www.example.com/")!), consumerKey: "consumer", consumerSecret: "secret")

    func testSignatureForMessage_Simple() {
        let signature = oAuth1.signature(for: "simon says", key: "abcedfg123456789")
        XCTAssertEqual(signature, "vyeIZc3+tF6F3i95IEV+AJCWBYQ=")
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
}
