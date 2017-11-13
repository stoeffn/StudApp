//
//  Semester.swift
//  StudKit
//
//  Created by Steffen Ryll on 08.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

@objc(Semester)
public final class Semester: NSManagedObject, CDCreatable, CDIdentifiable, CDUpdatable {
    @NSManaged public var id: String
    @NSManaged public var title: String
    @NSManaged public var beginDate: Date
    @NSManaged public var endDate: Date
    @NSManaged public var coursesBeginDate: Date
    @NSManaged public var coursesEndDate: Date

    @NSManaged public var courses: Set<Course>
    @NSManaged public var state: SemesterState

    public required convenience init(createIn context: NSManagedObjectContext) {
        self.init(context: context)
        state = SemesterState(createIn: context)
    }
}

// MARK: - Utilities

public extension Semester {
    public var isCurrent: Bool {
        let now = Date()
        return now >= beginDate && now <= endDate
    }

    public var monthRange: String {
        return "\(beginDate.formattedMonthAndYear) – \(endDate.formattedMonthAndYear)"
    }
}

// MARK: - Core Data Operations

extension Semester {
    public static func fetch(from beginSemester: Semester, to endSemester: Semester? = nil,
                             in context: NSManagedObjectContext) throws -> [Semester] {
        let endDate = endSemester?.endDate ?? .distantFuture
        let predicate = NSPredicate(format: "beginDate >= %@ AND endDate <= %@", beginSemester.beginDate as CVarArg,
                                    endDate as CVarArg)
        let request = fetchRequest(predicate: predicate, sortDescriptors: [])
        return try context.fetch(request)
    }

    public static var sortedFetchRequest: NSFetchRequest<Semester> {
        let sortDescriptor = NSSortDescriptor(keyPath: \Semester.beginDate, ascending: false)
        return fetchRequest(predicate: NSPredicate(value: true), sortDescriptors: [sortDescriptor],
                            relationshipKeyPathsForPrefetching: ["state"])
    }

    public static var nonHiddenFetchRequest: NSFetchRequest<Semester> {
        let predicate = NSPredicate(format: "state.isHidden == NO")
        return fetchRequest(predicate: predicate, relationshipKeyPathsForPrefetching: ["state"])
    }

    public var coursesFetchRequest: NSFetchRequest<Course> {
        let predicate = NSPredicate(format: "%@ IN semesters", self)
        let sortDescriptors = [NSSortDescriptor(keyPath: \Course.title, ascending: true)]
        return Course.fetchRequest(predicate: predicate, sortDescriptors: sortDescriptors,
                                   relationshipKeyPathsForPrefetching: ["state"])
    }
}
