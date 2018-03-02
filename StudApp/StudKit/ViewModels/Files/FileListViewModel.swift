//
//  FileListViewModel.swift
//  StudKit
//
//  Created by Steffen Ryll on 12.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

/// Manages a list of files in the course or folder given. In case of a course, it manages its root files.
///
/// In order to display initial data, you must call `fetch()`. Changes in the view context are automatically propagated to
/// `delegate`. This class also supports updating data from the server.
public final class FileListViewModel: FetchedResultsControllerDataSourceSection {
    public typealias Row = File

    private let coreDataService = ServiceContainer.default[CoreDataService.self]

    public private(set) lazy var fetchedResultControllerDelegateHelper = FetchedResultsControllerDelegateHelper(delegate: self)
    public weak var delegate: DataSourceSectionDelegate?

    public let filesContaining: FilesContaining

    /// Creates a new file list view model for the given folder's contents.
    public init(filesContaining: FilesContaining) {
        self.filesContaining = filesContaining

        controller.delegate = fetchedResultControllerDelegateHelper
    }

    public private(set) lazy var controller: NSFetchedResultsController<FileState> = NSFetchedResultsController(
        fetchRequest: filesContaining.childFileStatesFetchRequest, managedObjectContext: coreDataService.viewContext,
        sectionNameKeyPath: nil, cacheName: nil)

    public func row(from object: FileState) -> File {
        return object.file
    }

    public func object(from row: File) -> FileState {
        return row.state
    }

    /// Updates data from the server.
    public func update(completion: ResultHandler<Void>? = nil) {
        // TODO
    }
}
