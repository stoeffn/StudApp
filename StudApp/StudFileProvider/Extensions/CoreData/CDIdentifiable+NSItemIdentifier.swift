//
//  CDIdentifiable+NSItemIdentifier.swift
//  StudFileProvider
//
//  Created by Steffen Ryll on 28.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit

extension CDIdentifiable {
    static func itemIdentifier(forId id: String) -> NSFileProviderItemIdentifier {
        let itemIdentifier = String(describing: Self.self).lowercased().appending("-").appending(id)
        return NSFileProviderItemIdentifier(rawValue: itemIdentifier)
    }

    var itemIdentifier: NSFileProviderItemIdentifier {
        return Self.itemIdentifier(forId: id)
    }
}
