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

/// Given an element getter, this iterator iterates all integer values in `range`.
///
/// This class is useful when iterating over a data source that does not expose its underlying array.
public struct RangeIterator<Element>: IteratorProtocol {
    private var currentIndex: Int
    private var range: CountableRange<Int>
    private var elementAt: (Int) -> Element

    /// Creates a new range iterator.
    ///
    /// - Parameters:
    ///   - range: Index range to iterate.
    ///   - elementAt: Closure that gets an element at the index given.
    init(range: CountableRange<Int>, elementAt: @escaping (Int) -> Element) {
        currentIndex = range.lowerBound
        self.range = range
        self.elementAt = elementAt
    }

    public mutating func next() -> Element? {
        defer { currentIndex += 1 }
        guard currentIndex < range.upperBound else { return nil }
        return elementAt(currentIndex)
    }
}
