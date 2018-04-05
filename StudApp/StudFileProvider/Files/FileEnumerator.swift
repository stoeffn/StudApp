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

/// Enumerates folders and documents inside a course or folder.
final class FileEnumerator: CachingFileProviderEnumerator {
    private let itemIdentifier: NSFileProviderItemIdentifier
    private let viewModel: FileListViewModel

    // MARK: - Life Cycle

    /// Creates a new enumerator for folders and documents.
    ///
    /// - Parameter itemIdentifier: Item identifier for the containing item, which can either be a folder or course.
    init(itemIdentifier: NSFileProviderItemIdentifier) {
        self.itemIdentifier = itemIdentifier

        let coreDataService = ServiceContainer.default[CoreDataService.self]

        let objectIdentifier = ObjectIdentifier(rawValue: itemIdentifier.rawValue)
        guard let object = try? objectIdentifier?.fetch(in: coreDataService.viewContext) else {
            fatalError("Cannot get model for item with identifier '\(itemIdentifier)'.")
        }
        guard let container = object as? FilesContaining & NSManagedObject else {
            fatalError("Cannot enumerate files in item with identifier '\(itemIdentifier)'.")
        }

        viewModel = FileListViewModel(container: container)

        super.init()

        viewModel.delegate = cache
        viewModel.fetch()
        viewModel.update()
    }

    // MARK: - Providing Items

    override var items: [NSFileProviderItem] {
        return viewModel.map { $0.fileProviderItem }
    }
}
