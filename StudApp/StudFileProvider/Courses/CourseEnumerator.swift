//
//  CourseEnumerator.swift
//  StudFileProvider
//
//  Created by Steffen Ryll on 11.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit

/// Enumerates all courses.
final class CourseEnumerator: CachingFileProviderEnumerator {
    private let viewModel: CourseListViewModel

    // MARK: - Life Cycle

    /// Creates a new course enumerator.
    init(user: User) {
        viewModel = CourseListViewModel(user: user)

        super.init()

        viewModel.delegate = cache
        viewModel.fetch()
        viewModel.update()
    }

    // MARK: - Providing Items

    override var items: [NSFileProviderItem] {
        return viewModel.map { $0.fileProviderItem }
    }
}
