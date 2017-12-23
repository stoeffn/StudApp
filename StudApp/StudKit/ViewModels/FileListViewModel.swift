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
public final class FileListViewModel: NSObject {
    private let coreDataService = ServiceContainer.default[CoreDataService.self]

    public let course: Course

    public let folder: File?

    public weak var delegate: DataSourceSectionDelegate?

    /// Creates a new file list view model for the given course's root files.
    public init(course: Course) {
        self.course = course
        folder = nil
        super.init()

        controller.delegate = self
    }

    /// Creates a new file list view model for the given folder's contents.
    public init(folder: File) {
        course = folder.course
        self.folder = folder
        super.init()

        controller.delegate = self
    }

    public convenience init?(courseId: String) {
        let coreDataService = ServiceContainer.default[CoreDataService.self]
        guard
            let optionalCourse = try? Course.fetch(byId: courseId, in: coreDataService.viewContext),
            let course = optionalCourse
        else { return nil }
        self.init(course: course)
    }

    public convenience init?(folderId: String) {
        let coreDataService = ServiceContainer.default[CoreDataService.self]
        guard
            let optionalFolder = try? File.fetch(byId: folderId, in: coreDataService.viewContext),
            let folder = optionalFolder
        else { return nil }
        self.init(folder: folder)
    }

    private(set) lazy var controller: NSFetchedResultsController<FileState>
        = NSFetchedResultsController(fetchRequest: folder?.childrenFetchRequest ?? course.rootFilesFetchRequest,
                                     managedObjectContext: coreDataService.viewContext, sectionNameKeyPath: nil, cacheName: nil)

    /// Fetches initial data.
    public func fetch() {
        try? controller.performFetch()
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

    public func index(for file: File) -> Int? {
        return controller.indexPath(forObject: file.state)?.row
    }
}

// MARK: - Data Source Section

extension FileListViewModel: DataSourceSection {
    public typealias Row = File

    public var numberOfRows: Int {
        return controller.sections?.first?.numberOfObjects ?? 0
    }

    public subscript(rowAt index: Int) -> File {
        return controller.object(at: IndexPath(row: index, section: 0)).file
    }
}

// MARK: - Fetched Results Controller Delegate

extension FileListViewModel: NSFetchedResultsControllerDelegate {
    public func controllerWillChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.dataWillChange(in: self)
    }

    public func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.dataDidChange(in: self)
    }

    public func controller(_: NSFetchedResultsController<NSFetchRequestResult>, didChange object: Any,
                           at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let state = object as? FileState else { fatalError() }
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { return }
            delegate?.data(changedIn: state.file, at: indexPath.row, change: .insert, in: self)
        case .delete:
            guard let indexPath = indexPath else { return }
            delegate?.data(changedIn: state.file, at: indexPath.row, change: .delete, in: self)
        case .update:
            guard let indexPath = indexPath else { return }
            delegate?.data(changedIn: state.file, at: indexPath.row, change: .update(state.file), in: self)
        case .move:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
            delegate?.data(changedIn: state.file, at: indexPath.row, change: .move(to: newIndexPath.row), in: self)
        }
    }
}
