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

    lazy var fetchedResultControllerDelegateHelper = FetchedResultsControllerDelegateHelper(delegate: self)

    public let course: Course

    public let folder: File?

    public weak var delegate: DataSourceSectionDelegate?

    /// Creates a new file list view model for the given course's root files.
    public init(course: Course) {
        self.course = course
        folder = nil

        controller.delegate = fetchedResultControllerDelegateHelper
    }

    /// Creates a new file list view model for the given folder's contents.
    public init(folder: File) {
        course = folder.course
        self.folder = folder

        controller.delegate = fetchedResultControllerDelegateHelper
    }

    private(set) lazy var controller: NSFetchedResultsController<FileState> = NSFetchedResultsController(
        fetchRequest: folder?.childrenFetchRequest ?? course.rootFilesFetchRequest,
        managedObjectContext: coreDataService.viewContext, sectionNameKeyPath: nil, cacheName: nil)

    func row(from object: FileState) -> File {
        return object.file
    }

    func object(from row: File) -> FileState {
        return row.state
    }

    /// Updates data from the server. Please note that this method not only updates one folder but the course's whole file tree.
    public func update(handler: ResultHandler<Void>? = nil) {
        coreDataService.performBackgroundTask { context in
            self.course.updateFiles(in: context) { result in
                try? context.saveWhenChanged()
                try? self.coreDataService.viewContext.saveWhenChanged()
                handler?(result.replacingValue(()))
            }
        }
    }

    public var title: String {
        return folder?.title ?? course.title
    }
}
