//
//  Segues.swift
//  StudApp
//
//  Created by Steffen Ryll on 07.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit

enum Segues : Routes {
    case signIn

    var identifier: String {
        switch self {
        case .signIn: return "signInSegue"
        }
    }
}
