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

/// Something that can be localized.
///
/// - Remark: `Localizable.strings` and `Localizable.stringsdict` are expected in the `StudKit` bundle.
public protocol Localizable: CustomStringConvertible, RawRepresentable {
    /// Returns a localized string with interpolated parameters.
    ///
    /// - Parameters:
    ///   - language: Language code to use. Please note that only the part before "-" will be respected. Defaults to the current
    ///               language.
    ///   - arguments: Arguments to be interpolated into the localized string.
    /// - Returns: Localized string with interpolated parameters.
    /// - Remark: Missing localizations will be highlighted by pound symbols.
    func localized(language: String?, _ arguments: CVarArg...) -> String

    /// Localized string without any interpolation.
    ///
    /// - Remark: Missing localizations will be highlighted by pound symbols.
    var localized: String { get }
}

// MARK: - Localizing

public extension Localizable {
    private var localizationKey: String {
        return "\(type(of: self)).\(rawValue)"
    }

    private func bundle(forLanguage language: String? = nil) -> Bundle {
        guard
            let languageCode = language?.split(separator: "-").first,
            let path = App.kitBundle.path(forResource: String(languageCode), ofType: "lproj"),
            let bundle = Bundle(path: path)
        else { return App.kitBundle }
        return bundle
    }

    public func localized(language: String? = nil, _ arguments: CVarArg...) -> String {
        let format = bundle(forLanguage: language).localizedString(forKey: localizationKey, value: localizationKey, table: nil)
        return String(format: format, arguments: arguments)
    }

    public var localized: String {
        return localized()
    }

    var description: String {
        return localized
    }
}
