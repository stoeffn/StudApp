//
//  Routes+Utils.swift
//  StudFileProviderUI
//
//  Created by Steffen Ryll on 06.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import FileProviderUI
import StudKit

extension Routes {
    init?(actionIdentifier: String, itemIdentifiers _: [NSFileProviderItemIdentifier]) {
        switch actionIdentifier {
        default:
            return nil
        }
    }

    init?(error: Error) {
        switch error {
        case let error as NSFileProviderError where error == NSFileProviderError(.notAuthenticated):
            self = .signIn
        default:
            return nil
        }
    }
}
