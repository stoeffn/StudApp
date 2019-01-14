//
//  StudApp—Stud.IP to Go
//  Copyright © 2018, Steffen Ryll
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see http://www.gnu.org/licenses/.
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
    public let showsHiddenCourses: Bool

    /// Creates a new course list view model managing all courses.
    public init(user: User, showsHiddenCourses: Bool = false) {
        self.user = user
        self.showsHiddenCourses = showsHiddenCourses

        semester = nil
        respectsCollapsedState = false
        isCollapsed = false

        controller.delegate = fetchedResultControllerDelegateHelper
    }

    /// Creates a new course list view model managing the given semester's courses.
    public init(user: User, semester: Semester, respectsCollapsedState: Bool = false, showsHiddenCourses: Bool = false) {
        self.user = user
        self.semester = semester
        self.respectsCollapsedState = respectsCollapsedState
        self.showsHiddenCourses = showsHiddenCourses

        isCollapsed = semester.state.isCollapsed
        controller.delegate = fetchedResultControllerDelegateHelper
    }

    public private(set) lazy var controller: NSFetchedResultsController<Course> = NSFetchedResultsController(
        fetchRequest: user.authoredCoursesFetchRequest(in: semester, includingHidden: showsHiddenCourses),
        managedObjectContext: coreDataService.viewContext, sectionNameKeyPath: nil, cacheName: nil
    )

    /// Fetches initial data.
    public func fetch() {
        controller.fetchRequest.predicate = isCollapsed && respectsCollapsedState
            ? NSPredicate(value: false)
            : user.authoredCoursesFetchRequest(in: semester, includingHidden: showsHiddenCourses).predicate ?? NSPredicate(value: true)
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
