//
//  String+Utils.swift
//  StudKit
//
//  Created by Steffen Ryll on 04.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public extension String {
    /// Returns `nil` in case of an empty string. Otherwise, this method returns the string itself.
    public var nilWhenEmpty: String? {
        return isEmpty ? nil : self
    }
}
