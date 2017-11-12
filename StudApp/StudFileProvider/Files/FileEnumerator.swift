//
//  FileEnumerator.swift
//  StudFileProvider
//
//  Created by Steffen Ryll on 11.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import StudKit

final class FileEnumerator: CachingFileEnumerator {
    private let viewModel: FileListViewModel

    override init(itemIdentifier: NSFileProviderItemIdentifier) {
        let coreDataService = ServiceContainer.default[CoreDataService.self]
        guard let model = try? FileProviderExtension.model(for: itemIdentifier, in: coreDataService.viewContext) else {
            fatalError("Cannot get model for item with identifier '\(itemIdentifier)'.")
        }

        switch model {
        case let course as Course:
            viewModel = FileListViewModel(course: course)
        case let folder as File:
            viewModel = FileListViewModel(course: folder.course, parentFolder: folder)
        default:
            fatalError("Cannot list files in item with identifier '\(itemIdentifier)'.")
        }

        super.init(itemIdentifier: itemIdentifier)

        viewModel.delegate = cache
        viewModel.fetch()
        viewModel.update()
    }

    override var items: [NSFileProviderItem] {
        return viewModel.flatMap { try? $0.fileProviderItem(context: coreDataService.viewContext) }
    }
}
