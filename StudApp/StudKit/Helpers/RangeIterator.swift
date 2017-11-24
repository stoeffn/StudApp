//
//  RangeIterator.swift
//  StudKit
//
//  Created by Steffen Ryll on 11.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
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
