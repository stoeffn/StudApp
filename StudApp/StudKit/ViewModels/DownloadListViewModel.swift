//
//  DownloadListViewModel.swift
//  StudKit
//
//  Created by Steffen Ryll on 17.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

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

    /// Creates a new download list view model managing downloaded documents.
    public init() {
        controller.delegate = fetchedResultControllerDelegateHelper
    }

    public private(set) lazy var controller: NSFetchedResultsController<FileState> = NSFetchedResultsController(
        fetchRequest: File.downloadedStatesFetchRequest, managedObjectContext: coreDataService.viewContext,
        sectionNameKeyPath: "file.course.title", cacheName: nil)

    public func section(from sectionInfo: NSFetchedResultsSectionInfo) -> Course? {
        return (sectionInfo.objects?.first as? FileState)?.file.course
    }

    public func row(from object: FileState) -> File {
        return object.file
    }

    public func object(from row: File) -> FileState {
        return row.state
    }

    /// Fetches data matching the search term given. An `nil` or empty search term matches all items.
    public func fetch(searchTerm: String? = nil) {
        controller.fetchRequest.predicate = File.downloadedPredicate(forSearchTerm: searchTerm)
        try? controller.performFetch()
    }

    public func removeDownload(_ file: File) -> Bool {
        do {
            try file.removeDownload()
            return true
        } catch {
            return false
        }
    }
}
