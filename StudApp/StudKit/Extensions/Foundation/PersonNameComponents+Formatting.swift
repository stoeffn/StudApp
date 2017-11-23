//
//  PersonNameComponents+Formatting.swift
//  StudKit
//
//  Created by Steffen Ryll on 23.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public extension PersonNameComponents {
    /// Returns a string formatted for a given `NSPersonNameComponents` object using the provided style and options.
    func formatted(style: PersonNameComponentsFormatter.Style = .default,
                   options: PersonNameComponentsFormatter.Options = []) -> String {
        return PersonNameComponentsFormatter.localizedString(from: self, style: style, options: options)
    }
}
