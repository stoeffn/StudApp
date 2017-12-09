//
//  FileEnumerator.swift
//  StudFileProvider
//
//  Created by Steffen Ryll on 11.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import StudKit

/// Enumerates folders and documents inside a course or folder.
final class FileEnumerator: CachingFileEnumerator {
    private let itemIdentifier: NSFileProviderItemIdentifier
    private let viewModel: FileListViewModel

    // MARK: - Life Cycle

    /// Creates a new enumerator for folders and documents.
    ///
    /// - Parameter itemIdentifier: Item identifier for the containing item, which can either be a folder or course.
    init(itemIdentifier: NSFileProviderItemIdentifier) {
        self.itemIdentifier = itemIdentifier

        let coreDataService = ServiceContainer.default[CoreDataService.self]

        guard let model = try? FileProviderExtension.model(for: itemIdentifier, in: coreDataService.viewContext) else {
            fatalError("Cannot get model for item with identifier '\(itemIdentifier)'.")
        }

        switch model {
        case let course as Course:
            viewModel = FileListViewModel(course: course)
        case let folder as File:
            viewModel = FileListViewModel(folder: folder)
        default:
            fatalError("Cannot enumerate files in item with identifier '\(itemIdentifier)'.")
        }

        super.init()

        viewModel.delegate = cache
        viewModel.fetch()
        viewModel.update()
    }

    // MARK: - Providing Items

    override var items: [NSFileProviderItem] {
        return viewModel.flatMap { try? $0.fileProviderItem(context: coreDataService.viewContext) }
    }
}
