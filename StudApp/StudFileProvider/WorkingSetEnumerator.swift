//
//  WorkingSetEnumerator.swift
//  StudFileProvider
//
//  Created by Steffen Ryll on 11.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import StudKit

final class WorkingSetEnumerator: CachingFileEnumerator {
    private let viewModels: [WorkingSetViewModel]

    // MARK: - Life Cycle

    override init(itemIdentifier: NSFileProviderItemIdentifier) {
        viewModels = [
            WorkingSetViewModel(fetchRequest: Semester.workingSetFetchRequest as! NSFetchRequest<NSFetchRequestResult>),
            WorkingSetViewModel(fetchRequest: Course.workingSetFetchRequest as! NSFetchRequest<NSFetchRequestResult>),
            WorkingSetViewModel(fetchRequest: File.workingSetFetchRequest as! NSFetchRequest<NSFetchRequestResult>),
        ]

        super.init(itemIdentifier: itemIdentifier)

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
