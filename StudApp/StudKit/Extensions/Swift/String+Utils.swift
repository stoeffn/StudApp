//
//  String+Utils.swift
//  StudKit
//
//  Created by Steffen Ryll on 04.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import Foundation

public extension String {
    /// Returns `nil` in case of an empty string. Otherwise, this method returns the string itself.
    public var nilWhenEmpty: String? {
        return isEmpty ? nil : self
    }

    /// Returns a localized string with this key and interpolated parameters.
    ///
    /// - Parameter arguments: Arguments to be interpolated into the localized string.
    /// - Returns: Localized string with interpolated parameters.
    public func localized(_ arguments: CVarArg...) -> String {
        return String(format: localized, arguments: arguments)
    }

    /// Returns a localized string with this key.
    ///
    /// - Parameters:
    ///   - comment: Optional comment describing the use case.
    /// - Returns: Localized string with interpolated parameters.
    public var localized: String {
        return StudKitServiceProvider.kitBundle.localizedString(forKey: self, value: "###\(self)###", table: nil)
    }
}
