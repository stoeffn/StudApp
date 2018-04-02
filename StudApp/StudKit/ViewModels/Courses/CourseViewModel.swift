//
//  CourseViewModel.swift
//  StudKit
//
//  Created by Steffen Ryll on 09.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public typealias TitleAndValue<Value> = (title: String, value: Value)

public final class CourseViewModel {
    public let course: Course

    public init(course: Course) {
        self.course = course
    }

    private var rows: [TitleAndValue<String?>] {
        return [
            ("Course Number".localized, course.number),
            ("Location".localized, course.location),
        ]
    }
}

extension CourseViewModel: DataSourceSection {
    public typealias Row = TitleAndValue<String?>

    public var numberOfRows: Int {
        return rows
            .compactMap { $0.value }
            .count
    }

    public subscript(rowAt index: Int) -> TitleAndValue<String?> {
        let fieldIndex = rows.enumerated()
            .filter { $1.value != nil }
            .dropFirst(index)
            .first?.offset ?? 0
        let nilFieldsCount = rows[0 ... fieldIndex]
            .filter { $0.value == nil }
            .count
        return rows[index + nilFieldsCount]
    }
}
