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
public final class DownloadListViewModel: NSObject {
    private let coreDataService = ServiceContainer.default[CoreDataService.self]
    private let fileService = ServiceContainer.default[CourseService.self]

    public weak var delegate: DataSourceDelegate?

    /// Creates a new download list view model managing downloaded documents.
    public override init() {
        super.init()

        controller.delegate = self
    }

    private(set) lazy var controller: NSFetchedResultsController<FileState>
        = NSFetchedResultsController(fetchRequest: File.downloadedFetchRequest,
                                     managedObjectContext: coreDataService.viewContext, sectionNameKeyPath: "file.course.title",
                                     cacheName: nil)

    /// Fetches initial data.
    public func fetch() {
        try? controller.performFetch()
    }

    public func removeDownload(_ file: File) -> Bool {
        do {
            try file.removeDownload()
            try controller.performFetch()
            return true
        } catch {
            return false
        }
    }
}

// MARK: - Data Source Section

extension DownloadListViewModel: DataSource {
    public typealias Section = String?

    public typealias Row = File

    public var numberOfSections: Int {
        return controller.sections?.count ?? 0
    }

    public func numberOfRows(inSection index: Int) -> Int {
        return controller.sections?[index].numberOfObjects ?? 0
    }

    public subscript(sectionAt index: Int) -> String? {
        return controller.sections?[index].name
    }

    public subscript(rowAt indexPath: IndexPath) -> File {
        return controller.object(at: indexPath).file
    }

    public var sectionIndexTitles: [String]? {
        return controller.sectionIndexTitles
    }

    public func section(forSectionIndexTitle title: String, at index: Int) -> Int {
        return controller.section(forSectionIndexTitle: title, at: index)
    }
}

// MARK: - Fetched Results Controller Delegate

extension DownloadListViewModel: NSFetchedResultsControllerDelegate {
    public func controllerWillChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.dataWillChange(in: self)
    }

    public func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.dataDidChange(in: self)
    }

    public func controller(_: NSFetchedResultsController<NSFetchRequestResult>,
                           didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex index: Int,
                           for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            delegate?.data(changedIn: sectionInfo.name, at: index, change: .insert, in: self)
        case .delete:
            delegate?.data(changedIn: sectionInfo.name, at: index, change: .delete, in: self)
        case .update:
            delegate?.data(changedIn: sectionInfo.name, at: index, change: .update(sectionInfo.name), in: self)
        case .move:
            delegate?.data(changedIn: sectionInfo.name, at: index, change: .move(to: index), in: self)
        }
    }

    public func controller(_: NSFetchedResultsController<NSFetchRequestResult>, didChange object: Any, at indexPath: IndexPath?,
                           for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let fileState = object as? FileState else { fatalError() }
        let file = fileState.file
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { return }
            delegate?.data(changedIn: file, at: indexPath, change: .insert, in: self)
        case .delete:
            guard let indexPath = indexPath else { return }
            delegate?.data(changedIn: file, at: indexPath, change: .delete, in: self)
        case .update:
            guard let indexPath = indexPath else { return }
            delegate?.data(changedIn: file, at: indexPath, change: .update(file), in: self)
        case .move:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
            delegate?.data(changedIn: file, at: indexPath, change: .move(to: newIndexPath), in: self)
        }
    }
}
