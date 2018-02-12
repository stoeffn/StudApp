//
//  CourseResponse+CDConvertible.swift
//  StudKit
//
//  Created by Steffen Ryll on 27.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

extension CourseResponse: CDConvertible {
    @discardableResult
    func coreDataModel(in context: NSManagedObjectContext) throws -> NSManagedObject {
        let (course, _) = try Course.fetch(byId: id, orCreateIn: context)
        course.id = id
        course.number = number
        course.title = title
        course.subtitle = subtitle
        course.summary = summary
        course.location = location
        course.lecturers = try lecturers
            .flatMap { try $0.coreDataModel(in: context) as? User }
            .set

        let beginSemester = try Semester.fetch(byId: beginSemesterId, in: context)
        let endSemester = try Semester.fetch(byId: endSemesterId, in: context)
        course.semesters = try Semester.fetch(from: beginSemester, to: endSemester, in: context).set

        return course
    }
}
