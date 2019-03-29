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

import StudKit

/// State of something that can be converted to a file provider item, including a back-reference to the item itself.
public protocol FileProviderItemConvertibleState: AnyObject {
    /// Item convertible this state describes.
    var item: FileProviderItemConvertible { get }

    var favoriteRank: Int64 { get set }

    var lastUsedAt: Date? { get set }

    var tagData: Data? { get set }
}

// MARK: - Utilities

extension FileProviderItemConvertibleState {
    /// Whether this item is not in the user's favorites, i.e. has no favorite rank.
    public var isUnranked: Bool {
        return favoriteRank == fileProviderFavoriteRankUnranked
    }
}
