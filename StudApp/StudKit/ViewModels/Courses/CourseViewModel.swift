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
