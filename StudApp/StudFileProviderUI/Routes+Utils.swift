//
//  Routes+Utils.swift
//  StudFileProviderUI
//
//  Created by Steffen Ryll on 06.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit

extension Routes {
    init?(actionIdentifier: String, itemIdentifiers _: [NSFileProviderItemIdentifier]) {
        switch actionIdentifier {
        default:
            return nil
        }
    }

    init?(error: Error) {
        guard
            let error = error as? NSFileProviderError,
            let rawReason = error.userInfo[NSFileProviderError.reasonKey] as? String,
            let reason = NSFileProviderError.Reasons(rawValue: rawReason)
        else { return nil }

        switch reason {
        case .notSignedIn:
            self = .signIn { result in
                let context = ServiceContainer.default[ContextService.self]

                guard let error = result.error else {
                    context.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                    return
                }
                context.extensionContext?.cancelRequest(withError: error)
            }
        case .noVerifiedPurchase:
            self = .verification
        }
    }
}
