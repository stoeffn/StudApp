//
//  Segues.swift
//  StudKit
//
//  Created by Steffen Ryll on 07.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public enum Segues: Routes {
    case chooseOrganization

    case signIn(OrganizationRecord)

    public var identifier: String {
        switch self {
        case .chooseOrganization: return "chooseOrganization"
        case .signIn: return "signIn"
        }
    }
}
