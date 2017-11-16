//
//  DataSource.swift
//  RemonderKit
//
//  Created by Steffen Ryll on 19.09.17.
//  Copyright © 2017 Remonder. All rights reserved.
//

public protocol DataSource: Sequence {
    associatedtype Section
    associatedtype Row

    weak var delegate: DataSourceDelegate? { get set }

    var numberOfSections: Int { get }

    func numberOfRows(inSection index: Int) -> Int

    subscript(sectionAt _: Int) -> Section { get }

    subscript(rowAt _: IndexPath) -> Row { get }
}

// MARK: - Utilities

extension DataSource {
    public typealias Iterator = RangeIterator<Section>

    public func makeIterator() -> Iterator {
        return Iterator(range: 0 ..< numberOfSections) { index in self[sectionAt: index] }
    }
}
