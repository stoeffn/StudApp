//
//  RangeIterator.swift
//  StudKit
//
//  Created by Steffen Ryll on 11.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public struct RangeIterator<Element>: IteratorProtocol {
    private var currentIndex = 0
    var numberOfRows: Int
    var elementAt: (Int) -> Element

    init(numberOfRows: Int, elementAt: @escaping (Int) -> Element) {
        self.numberOfRows = numberOfRows
        self.elementAt = elementAt
    }

    public mutating func next() -> Element? {
        defer { currentIndex += 1 }
        guard currentIndex < numberOfRows - 1 else { return nil }
        return elementAt(currentIndex)
    }
}
