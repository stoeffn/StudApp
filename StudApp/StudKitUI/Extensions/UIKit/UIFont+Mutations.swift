//
//  UIFont+Mutations.swift
//  StudKitUI
//
//  Created by Steffen Ryll on 08.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
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
