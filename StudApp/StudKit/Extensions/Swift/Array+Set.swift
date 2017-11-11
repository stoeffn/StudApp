//
//  Array+Set.swift
//  StudKit
//
//  Created by Steffen Ryll on 30.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public extension Array where Element: Hashable {
    var set: Set<Element> {
        return Set(self)
    }
}
