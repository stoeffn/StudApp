//
//  SemesterEnumerator.swift
//  StudFileProvider
//
//  Created by Steffen Ryll on 11.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit

/// Enumerates all visible semesters.
final class SemesterEnumerator: CachingFileEnumerator {
    private let viewModel = SemesterListViewModel(fetchRequest: Semester.nonHiddenFetchRequest)

    // MARK: - Life Cycle

    /// Creates a new semester enumerator.
    override init() {
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
