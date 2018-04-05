//
//  StudApp—Stud.IP to Go
//  Copyright © 2018, Steffen Ryll
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see http://www.gnu.org/licenses/.
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
    public var localized: String {
        return App.kitBundle.localizedString(forKey: self, value: "###\(self)###", table: nil)
    }

    public var sanitizedAsFilename: String {
        return replacingOccurrences(of: "/", with: "⁄")
            .replacingOccurrences(of: ": ", with: "：")
            .replacingOccurrences(of: ":", with: "：")
    }
}
