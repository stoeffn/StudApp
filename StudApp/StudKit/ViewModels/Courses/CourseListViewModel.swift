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

    public private(set) lazy var fetchedResultControllerDelegateHelper = FetchedResultsControllerDelegateHelper(delegate: self)
    public weak var delegate: DataSourceSectionDelegate?

    public let user: User
    public let semester: Semester?
    public let respectsCollapsedState: Bool

    /// Creates a new course list view model managing all courses.
    public init(user: User) {
        self.user = user

        semester = nil
        respectsCollapsedState = false
        isCollapsed = false

        controller.delegate = fetchedResultControllerDelegateHelper
    }

    /// Creates a new course list view model managing the given semester's courses.
    public init(user: User, semester: Semester, respectsCollapsedState: Bool = false) {
        self.user = user
        self.semester = semester
        self.respectsCollapsedState = respectsCollapsedState

        isCollapsed = semester.state.isCollapsed
        controller.delegate = fetchedResultControllerDelegateHelper
    }

    public private(set) lazy var controller: NSFetchedResultsController<Course> = NSFetchedResultsController(
        fetchRequest: user.authoredCoursesFetchRequest(in: semester),
        managedObjectContext: coreDataService.viewContext, sectionNameKeyPath: nil, cacheName: nil)

    /// Fetches initial data.
    public func fetch() {
        controller.fetchRequest.predicate = isCollapsed && respectsCollapsedState
            ? NSPredicate(value: false)
            : user.authoredCoursesFetchRequest(in: semester).predicate ?? NSPredicate(value: true)
        try? controller.performFetch()
    }

    /// Updates data from the server.
    public func update(completion: (() -> Void)? = nil) {
        coreDataService.performBackgroundTask { context in
            self.user.in(context)
                .updateAuthoredCourses { _ in DispatchQueue.main.async { completion?() } }
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
