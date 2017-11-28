//
//  DataSourceSection.swift
//  StudKit
//
//  Created by Steffen Ryll on 19.09.17.
//  Copyright © 2017 Remonder. All rights reserved.
//

public protocol DataSourceSection: Sequence {
    associatedtype Row

    var numberOfRows: Int { get }

    subscript(rowAt _: Int) -> Row { get }
}

// MARK: - Iterating

extension DataSourceSection {
    public typealias Iterator = RangeIterator<Row>

    public func makeIterator() -> Iterator {
        return Iterator(range: 0 ..< numberOfRows) { index in self[rowAt: index] }
    }
}
