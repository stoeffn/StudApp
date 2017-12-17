//
//  NSFileProviderError+Reasons.swift
//  StudFileProvider
//
//  Created by Steffen Ryll on 17.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import FileProvider

@available(iOSApplicationExtension 11.0, *)
public extension NSFileProviderError {
    public enum Reasons: String {
        case notSignedIn
        case noVerifiedPurchase
    }

    public static let reasonKey = "reason"
}
