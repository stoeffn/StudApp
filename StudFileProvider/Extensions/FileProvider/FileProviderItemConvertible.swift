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

import CoreData
import StudKit

/// Something that can be converted to a file provider item, e.g. a course or file.
public protocol FileProviderItemConvertible: AnyObject {
    /// Current state of this item.
    var itemState: FileProviderItemConvertibleState { get }

    /// Converts this object to a file provider item.
    var fileProviderItem: NSFileProviderItem { get }

    func localUrl(in directory: BaseDirectories) -> URL

    func provide(at url: URL, completion: ((Error?) -> Void)?)
}

// MARK: - Operating on File Items

extension FileProviderItemConvertible where Self: NSFetchRequestResult {
    /// Request fetching all objects of this type that are in the working set, which includes recently used items, tagged items,
    /// and items marked as favorite.
    public static var workingSetFetchRequest: NSFetchRequest<Self> {
        let predicate = NSPredicate(format: "state.lastUsedAt != NIL OR state.tagData != NIL OR state.favoriteRank != %d",
                                    fileProviderFavoriteRankUnranked)
        return fetchRequest(predicate: predicate, relationshipKeyPathsForPrefetching: ["state"])
    }

    /// Fetches all objects of this type in the working set, which includes recently used items, tagged items, and items marked
    /// as favorite.
    public static func fetchItemsInWorkingSet(in context: NSManagedObjectContext) throws -> [Self] {
        return try context.fetch(workingSetFetchRequest)
    }
}
