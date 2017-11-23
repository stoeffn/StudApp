//
//  Course.swift
//  StudKit
//
//  Created by Steffen Ryll on 25.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

/// Course that a user can attend, e.g. a university class.
///
/// Besides containing some metadata such as a title and location, each course is alse the root node of a file structure.
@objc(Course)
public final class Course: NSManagedObject, CDCreatable, CDIdentifiable, CDUpdatable {
    @NSManaged public var id: String

    /// Course number internal to Stud.IP that can also be used for identifying a course.
    @NSManaged public var number: String?

    @NSManaged public var title: String

    @NSManaged public var subtitle: String?

    /// Short description of the course and/or summary of its contents.
    @NSManaged public var summary: String?

    /// Describes where this course is held.
    @NSManaged public var location: String?

    @NSManaged public var lecturers: Set<User>

    /// Course files contained at the root level. A file can either be a folder or document and the former may contain other
    /// files itself.
    @NSManaged public var files: Set<File>

    /// As a course can span multiple semesters, there is a set of semesters. However, most courses exist in one semester only.
    /// It is also important to know that—if contained in semesters `A` and `C`—a course should also be contained in `B`.
    @NSManaged public var semesters: Set<Semester>
    
    @NSManaged public var state: CourseState

    // MARK: - Life Cycle

    public required convenience init(createIn context: NSManagedObjectContext) {
        self.init(context: context)
        state = CourseState(createIn: context)
    }
}

// MARK: - Core Data Operations

extension Course {
    /// Request that fetches all files contained in `files`, i.e. documents and folders at the course's root.
    ///
    /// - Remark: This request uses file states instead of files in order to simplify monitoring changes using
    ///           `NSFetchedResultsController`.
    public var rootFilesFetchRequest: NSFetchRequest<FileState> {
        let predicate = NSPredicate(format: "file.course == %@ AND file.parent == NIL", self)
        return FileState.fetchRequest(predicate: predicate, relationshipKeyPathsForPrefetching: ["file"])
    }

    /// Fetches and returns the documents and folder at this course's root in the context given.
    public func fetchRootFiles(in context: NSManagedObjectContext) throws -> [File] {
        return try context.fetch(rootFilesFetchRequest).map { $0.file }
    }
}
