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

public final class FetchedDownloadsController: NSFetchedResultsController<File> {
    public override func sectionIndexTitle(forSectionName sectionName: String) -> String? {
        let name = sectionName
            .components(separatedBy: "-")
            .dropFirst()
            .joined(separator: "-")
        return super.sectionIndexTitle(forSectionName: name)
    }
}

/// Manages a list of downloaded documents.
///
/// In order to display initial data, you must call `fetch()`. Changes in the view context are automatically propagated to
/// `delegate`.
public final class DownloadListViewModel: FetchedResultsControllerDataSource {
    public typealias Section = Course
    public typealias Row = File

    private let coreDataService = ServiceContainer.default[CoreDataService.self]

    public private(set) lazy var fetchedResultControllerDelegateHelper = FetchedResultsControllerDelegateHelper(delegate: self)
    public weak var delegate: DataSourceDelegate?

    public let user: User

    /// Creates a new download list view model managing downloaded documents.
    public init(user: User) {
        self.user = user

        controller.delegate = fetchedResultControllerDelegateHelper
    }

    public private(set) lazy var controller: NSFetchedResultsController<File> = FetchedDownloadsController(
        fetchRequest: user.downloadsFetchRequest, managedObjectContext: coreDataService.viewContext,
        sectionNameKeyPath: "course.sectionId", cacheName: nil
    )

    public func section(from sectionInfo: NSFetchedResultsSectionInfo) -> Course? {
        return (sectionInfo.objects?.first as? File)?.course
    }

    /// Fetches data matching the search term given. An `nil` or empty search term matches all items.
    public func fetch(searchTerm: String? = nil) {
        controller.fetchRequest.predicate = user.downloadsPredicate(forSearchTerm: searchTerm)
        try? controller.performFetch()
    }

    @discardableResult
    public func removeDownload(_ file: File) -> Bool {
        do {
            try file.removeDownload()
            return true
        } catch {
            return false
        }
    }
}
