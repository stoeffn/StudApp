//
//  FileProviderItemConvertibleState.swift
//  StudFileProvider
//
//  Created by Steffen Ryll on 11.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import Foundation

/// State of something that can be converted to a file provider item, including a back-reference to the item itself.
public protocol FileProviderItemConvertibleState: class {
    /// Item convertible this state describes.
    var item: FileProviderItemConvertible { get }

    var favoriteRank: Int { get set }

    var lastUsedDate: Date? { get set }

    var tagData: Data? { get set }
}

// MARK: - Utilities

extension FileProviderItemConvertibleState {
    /// Whether this item is not in the user's favorites, i.e. has no favorite rank.
    public var isUnranked: Bool {
        return favoriteRank == Int(NSFileProviderFavoriteRankUnranked)
    }
}
