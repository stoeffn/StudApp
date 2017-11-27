//
//  Routes.swift
//  StudKit
//
//  Created by Steffen Ryll on 06.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public enum Routes {
    case chooseOrganization

    case signIn(OrganizationRecord)

    public var identifier: String {
        switch self {
        case .chooseOrganization: return "chooseOrganization"
        case .signIn: return "signIn"
        }
    }
}
