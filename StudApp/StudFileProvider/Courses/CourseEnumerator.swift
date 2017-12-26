//
//  CourseEnumerator.swift
//  StudFileProvider
//
//  Created by Steffen Ryll on 11.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit

/// Enumerates all courses in a semester.
@available(iOSApplicationExtension 11.0, *)
final class CourseEnumerator: CachingFileProviderEnumerator {
    private let itemIdentifier: NSFileProviderItemIdentifier
    private let viewModel: CourseListViewModel

    // MARK: - Life Cycle

    /// Creates a new course enumerator.
    ///
    /// - Parameter itemIdentifier: Item identifier for the containing item, which should be a course item.
    init(itemIdentifier: NSFileProviderItemIdentifier) {
        self.itemIdentifier = itemIdentifier

        let objectIdentifier = ObjectIdentifier(rawValue: itemIdentifier.rawValue)

        guard let semester = Semester.fetch(byObjectId: objectIdentifier) else {
            fatalError("Cannot find semester with identifier '\(itemIdentifier)'.")
        }

        viewModel = CourseListViewModel(semester: semester)

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
