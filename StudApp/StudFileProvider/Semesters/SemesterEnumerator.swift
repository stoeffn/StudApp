//
//  SemesterEnumerator.swift
//  StudFileProvider
//
//  Created by Steffen Ryll on 11.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit

final class SemesterEnumerator: CachingFileEnumerator {
    private let viewModel = SemesterListViewModel(fetchRequest: Semester.nonHiddenFetchRequest)

    override init(itemIdentifier: NSFileProviderItemIdentifier) {
        super.init(itemIdentifier: itemIdentifier)

        viewModel.delegate = cache
        viewModel.fetch()
        viewModel.update()
    }

    override var items: [NSFileProviderItem] {
        return viewModel.flatMap { try? $0.fileProviderItem(context: coreDataService.viewContext) }
    }
}
