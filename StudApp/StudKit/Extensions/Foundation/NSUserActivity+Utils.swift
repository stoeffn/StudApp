//
//  NSUserActivity+Utils.swift
//  StudKit
//
//  Created by Steffen Ryll on 22.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreSpotlight

public extension NSUserActivity {
    public var objectIdentifier: ObjectIdentifier? {
        get {
            guard let rawValue = userInfo?[CSSearchableItemActivityIdentifier] as? String else { return nil }
            return ObjectIdentifier(rawValue: rawValue)
        }
        set {
            requiredUserInfoKeys = [CSSearchableItemActivityIdentifier]
            addUserInfoEntries(from: [CSSearchableItemActivityIdentifier: newValue?.rawValue ?? ""])
        }
    }
}
