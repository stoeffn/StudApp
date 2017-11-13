//
//  Course.swift
//  StudKit
//
//  Created by Steffen Ryll on 25.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

@objc(Course)
public final class Course: NSManagedObject, CDCreatable, CDIdentifiable, CDUpdatable {
    @NSManaged public var id: String
    @NSManaged public var number: String?
    @NSManaged public var title: String
    @NSManaged public var subtitle: String?
    @NSManaged public var summary: String?
    @NSManaged public var location: String?
    @NSManaged public var lecturers: Set<User>
    @NSManaged public var files: Set<File>

    @NSManaged public var semesters: Set<Semester>
    @NSManaged public var state: CourseState

    public required convenience init(createIn context: NSManagedObjectContext) {
        self.init(context: context)
        state = CourseState(createIn: context)
    }
}

// MARK: - Core Data Operations

extension Course {
    public var rootFilesFetchRequest: NSFetchRequest<File> {
        let predicate = NSPredicate(format: "course == %@ AND parent == NIL", self)
        return File.fetchRequest(predicate: predicate, relationshipKeyPathsForPrefetching: ["state"])
    }

    public func fetchRootFiles(in context: NSManagedObjectContext) throws -> [File] {
        return try context.fetch(rootFilesFetchRequest)
    }
}
