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

// MARK: - Utilities

public extension DataSourceSection {
    public var isEmpty: Bool {
        return numberOfRows == 0
    }
}

// MARK: - Iterating

public extension DataSourceSection {
    public func makeIterator() -> RangeIterator<Row> {
        return RangeIterator(range: 0 ..< numberOfRows) { self[rowAt: $0] }
    }
}
