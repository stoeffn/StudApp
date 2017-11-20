//
//  CourseEnumerator.swift
//  StudFileProvider
//
//  Created by Steffen Ryll on 11.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit

final class CourseEnumerator: CachingFileEnumerator {
    private let viewModel: CourseListViewModel

    override init(itemIdentifier: NSFileProviderItemIdentifier) {
        let coreDataService = ServiceContainer.default[CoreDataService.self]
        guard let semester = try? Semester.fetch(byId: itemIdentifier.id, in: coreDataService.viewContext),
            let unwrappedSemester = semester else { fatalError() }

        viewModel = CourseListViewModel(semester: unwrappedSemester)

        super.init(itemIdentifier: itemIdentifier)

        viewModel.delegate = cache
        viewModel.fetch()
        viewModel.update()
    }

    override var items: [NSFileProviderItem] {
        return viewModel.flatMap { try? $0.fileProviderItem(context: coreDataService.viewContext) }
    }
}
