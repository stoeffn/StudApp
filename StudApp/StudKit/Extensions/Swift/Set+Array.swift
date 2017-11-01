//
//  Set+Array.swift
//  StudKit
//
//  Created by Steffen Ryll on 30.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public extension Set {
    var array: [Element] {
        return Array(self)
    }
}
