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

public protocol DataSource: Sequence {
    associatedtype Section

    associatedtype Row

    var numberOfSections: Int { get }

    func numberOfRows(inSection index: Int) -> Int

    subscript(sectionAt _: Int) -> Section { get }

    subscript(rowAt _: IndexPath) -> Row { get }

    var sectionIndexTitles: [String]? { get }

    func section(forSectionIndexTitle title: String, at index: Int) -> Int
}

// MARK: - Default Implementation

public extension DataSource {
    var sectionIndexTitles: [String]? {
        return nil
    }

    func section(forSectionIndexTitle _: String, at _: Int) -> Int {
        fatalError("Cannot get section for section index title: Not implemented.")
    }
}

// MARK: - Utilities

public extension DataSource {
    var isEmpty: Bool {
        return numberOfSections == 0
    }
}

// MARK: - Iterating

extension DataSource {
    public func makeIterator() -> RangeIterator<Section> {
        return RangeIterator(range: 0 ..< numberOfSections) { self[sectionAt: $0] }
    }
}
