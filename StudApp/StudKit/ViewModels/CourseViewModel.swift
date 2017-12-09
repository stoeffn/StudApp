//
//  CourseViewModel.swift
//  StudKit
//
//  Created by Steffen Ryll on 09.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public final class CourseViewModel {
    public let course: Course

    public init(course: Course) {
        self.course = course
    }

    private var infoFields: [String?] {
        return [course.number, course.location, course.summary]
    }

    public var numberOfInfoFields: Int {
        return infoFields
            .flatMap { $0 }
            .count
    }

    public func adjustedIndexForInfoField(at index: Int) -> Int {
        let fieldIndex = infoFields.enumerated()
            .filter { $1 != nil }
            .dropFirst(index)
            .first?.offset ?? 0
        let nilFieldsCount = infoFields[0...fieldIndex]
            .filter { $0 == nil }
            .count
        return index + nilFieldsCount
    }
}
