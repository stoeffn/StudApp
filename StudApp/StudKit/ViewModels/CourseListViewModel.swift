//
//  CourseListViewModel.swift
//  StudKit
//
//  Created by Steffen Ryll on 03.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

/// Manages a list of courses in the semester given.
///
/// In order to display initial data, you must call `fetch()`. Changes in the view context are automatically propagated to
/// `delegate`. This class also supports updating data from the server.
public final class CourseListViewModel: FetchedResultsControllerDataSourceSection {
    public typealias Row = Course

    private let coreDataService = ServiceContainer.default[CoreDataService.self]
    private let semester: Semester
    private let respectsCollapsedState: Bool

    lazy var fetchedResultControllerDelegateHelper = FetchedResultsControllerDelegateHelper(delegate: self)

    public weak var delegate: DataSourceSectionDelegate?

    /// Creates a new course list view model managing the given semester's courses.
    public init(semester: Semester, respectsCollapsedState: Bool = false) {
        self.semester = semester
        self.respectsCollapsedState = respectsCollapsedState
        isCollapsed = semester.state.isCollapsed

        controller.delegate = fetchedResultControllerDelegateHelper
    }

    private(set) lazy var controller: NSFetchedResultsController<CourseState> = NSFetchedResultsController(
        fetchRequest: semester.coursesFetchRequest, managedObjectContext: coreDataService.viewContext, sectionNameKeyPath: nil,
        cacheName: nil)

    func row(from object: CourseState) -> Course {
        return object.course
    }

    func object(from row: Course) -> CourseState {
        return row.state
    }

    /// Fetches initial data.
    public func fetch() {
        controller.fetchRequest.predicate = isCollapsed && respectsCollapsedState
            ? NSPredicate(value: false)
            : semester.coursesFetchRequest.predicate
        try? controller.performFetch()
    }

    /// Updates data from the server.
    public func update(handler: ResultHandler<Void>? = nil) {
        coreDataService.performBackgroundTask { context in
            Course.update(in: context) { result in
                try? context.saveWhenChanged()
                handler?(result.replacingValue(()))
            }
        }
    }

    public var isCollapsed: Bool {
        didSet {
            guard isCollapsed != oldValue else { return }

            delegate?.dataWillChange(in: self)
            for (index, row) in enumerated() {
                delegate?.data(changedIn: row, at: index, change: .delete, in: self)
            }
            fetch()
            for (index, row) in enumerated() {
                delegate?.data(changedIn: row, at: index, change: .insert, in: self)
            }
            delegate?.dataDidChange(in: self)
        }
    }
}

extension CourseListViewModel: Equatable {
    public static func == (lhs: CourseListViewModel, rhs: CourseListViewModel) -> Bool {
        return lhs.semester == rhs.semester
    }
}
