//
//  Course.swift
//  StudKit
//
//  Created by Steffen Ryll on 25.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

@objc(Course)
public final class Course : NSManagedObject, CDCreatable, CDIdentifiable, CDUpdatable, FilesContaining {
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

    public func updateFiles(in context: NSManagedObjectContext, handler: @escaping ResultHandler<[File]>) {
        let studIp = ServiceContainer.default[StudIpService.self]
        studIp.api.requestCompleteCollection(.files(forCourseId: id)) { (result: Result<[FileModel]>) in
            File.update(using: result, in: context, handler: handler)
        }
    }

    public var filesFetchRequest: NSFetchRequest<File> {
        let predicate = NSPredicate(format: "course.id == %@ AND parent == NIL", id)
        return File.fetchRequest(predicate: predicate, relationshipKeyPathsForPrefetching: ["state"])
    }

    public static var visibleCoursesFetchRequest: NSFetchRequest<Course> {
        let predicate = NSPredicate(format: "state.isHidden == NO")
        return Course.fetchRequest(predicate: predicate, relationshipKeyPathsForPrefetching: ["state"])
    }

    public static func fetchVisibleCourses(in context: NSManagedObjectContext) throws -> [Course] {
        return try context.fetch(visibleCoursesFetchRequest)
    }

    public static func numberOfVisibleCourses(in context: NSManagedObjectContext) throws -> Int {
        return try context.count(for: visibleCoursesFetchRequest)
    }
}
