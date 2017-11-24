//
//  ActionRoutes.swift
//  StudFileProviderUI
//
//  Created by Steffen Ryll on 06.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import FileProviderUI
import StudKit

enum ActionRoutes: Routes {
    typealias RawValue = String

    case authenticate(context: FPUIActionExtensionContext)

    init?(actionIdentifier: String, context: FPUIActionExtensionContext, itemIdentifiers _: [NSFileProviderItemIdentifier]) {
        switch actionIdentifier {
        case "authenticate":
            self = .authenticate(context: context)
        default: return nil
        }
    }

    var identifier: String {
        switch self {
        case .authenticate: return "Authentication"
        }
    }
}
