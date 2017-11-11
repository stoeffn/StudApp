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

    public static var nonEmptyFetchRequest: NSFetchRequest<Semester> {
        let predicate = NSPredicate(format: "SUBQUERY(courses, $course, $course.state.isHidden == NO).@count > 0")
        let sortDescriptor = NSSortDescriptor(keyPath: \Semester.beginDate, ascending: false)
        return fetchRequest(predicate: predicate, sortDescriptors: [sortDescriptor],
                            relationshipKeyPathsForPrefetching: ["state"])
    }

    public static func fetchNonEmpty(in context: NSManagedObjectContext) throws -> [Semester] {
        return try context.fetch(nonEmptyFetchRequest)
    }

    public static func fetch(from beginSemester: Semester, to endSemester: Semester? = nil,
                             in context: NSManagedObjectContext) throws -> [Semester] {
        let endDate = endSemester?.endDate ?? .distantFuture
        let predicate = NSPredicate(format: "beginDate >= %@ AND endDate <= %@", beginSemester.beginDate as CVarArg,
                                    endDate as CVarArg)
        let request = fetchRequest(predicate: predicate, sortDescriptors: [])
        return try context.fetch(request)
    }

    public var coursesFetchRequest: NSFetchRequest<CourseState> {
        let predicate = NSPredicate(format: "isHidden == NO AND %@ IN course.semesters", self)
        let sortDescriptors = [
            NSSortDescriptor(keyPath: \CourseState.color?.orderId, ascending: true),
            NSSortDescriptor(keyPath: \CourseState.course.title, ascending: true),
        ]
        return CourseState.fetchRequest(predicate: predicate, sortDescriptors: sortDescriptors,
                                        relationshipKeyPathsForPrefetching: ["course"])
    }

    public var isCurrent: Bool {
        let now = Date()
        return now >= beginDate && now <= endDate
    }
}
