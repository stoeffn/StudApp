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

public extension UIFont {
    /// Returns a version of this font, adding the font traits given. May return the original font on failure.
    public func addingTraits(_ traits: UIFontDescriptorSymbolicTraits) -> UIFont {
        if let boldFontDescriptor = fontDescriptor.withSymbolicTraits([fontDescriptor.symbolicTraits, traits]) {
            return UIFont(descriptor: boldFontDescriptor, size: pointSize)
        }
        return self
    }

    /// Returns an italic version of this font.
    public var bold: UIFont {
        return addingTraits(.traitBold)
    }

    /// Returns an bold version of this font.
    public var italic: UIFont {
        return addingTraits(.traitItalic)
    }
}
