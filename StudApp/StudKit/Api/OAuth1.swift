//
//  OAuth1.swift
//  StudKit
//
//  Created by Steffen Ryll on 31.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import Foundation
import CommonCrypto

final class OAuth1<Routes: OAuth1Routes> {
    private let api: Api<Routes>

    init(api: Api<Routes> = Api<Routes>()) {
        self.api = api
    }

    func requestToken(handler: ResultHandler<(token: String, tokenSecret: String)>) {
        api.request(.requestToken) { result in
            print(result)
        }
    }

    func signature(for route: Routes, parameters: [URLQueryItem], key: String) -> String? {
        let method = route.method.rawValue.uppercased()
        let url = api.url(for: route)?.path
        let encodedParameters = parameters
            .sorted { $0.name > $1.name }
            .map { "\($0.name):\($0.value ?? "")" }
            .flatMap { $0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) }
            .joined(separator: "&")
        let signatureBase = [method, url, encodedParameters]
            .flatMap { $0?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) }
            .joined(separator: "&")
        return signature(for: signatureBase, key: key)
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
