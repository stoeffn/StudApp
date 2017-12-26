//
//  WorkingSetEnumerator.swift
//  StudFileProvider
//
//  Created by Steffen Ryll on 11.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import StudKit

/// Enumerates all files, eg. semesters, courses or documents, that are currently considered important. This includes any
/// items marked as favorite, recently used items, and tagged items.
final class WorkingSetEnumerator: CachingFileProviderEnumerator {
    private let viewModels: [WorkingSetViewModel]

    // MARK: - Life Cycle

    /// Creates a new working set enumerator for items currently considered important.
    override init() {
        viewModels = [
            WorkingSetViewModel(fetchRequest: Semester.workingSetFetchRequest as! NSFetchRequest<NSFetchRequestResult>),
            WorkingSetViewModel(fetchRequest: Course.workingSetFetchRequest as! NSFetchRequest<NSFetchRequestResult>),
            WorkingSetViewModel(fetchRequest: File.workingSetFetchRequest as! NSFetchRequest<NSFetchRequestResult>),
        ]

        super.init()

        for viewModel in viewModels {
            viewModel.delegate = cache
            viewModel.fetch()
        }
    }

    // MARK: - Providing Items

    override var items: [NSFileProviderItem] {
        return viewModels
            .flatMap { $0 }
            .flatMap { try? $0.fileProviderItem(context: coreDataService.viewContext) }
    }
}
