//
//  RangeIterator.swift
//  StudKit
//
//  Created by Steffen Ryll on 11.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public struct RangeIterator<Element>: IteratorProtocol {
    private var currentIndex: Int
    private var range: CountableRange<Int>
    private var elementAt: (Int) -> Element

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
