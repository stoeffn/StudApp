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

    var numberOfSections: Int { get }

    func numberOfRows(inSection index: Int) -> Int

    subscript(sectionAt _: Int) -> Section { get }

    subscript(rowAt _: IndexPath) -> Row { get }

    var sectionIndexTitles: [String]? { get }

    func section(forSectionIndexTitle title: String, at index: Int) -> Int
}

// MARK: - Default Implementation

public extension DataSource {
    public var sectionIndexTitles: [String]? {
        return nil
    }

    public func section(forSectionIndexTitle _: String, at _: Int) -> Int {
        fatalError("Cannot get section for section index title: Not implemented.")
    }
}

// MARK: - Utilities

public extension DataSource {
    public var isEmpty: Bool {
        return numberOfSections == 0
    }
}

// MARK: - Iterating

extension DataSource {
    public func makeIterator() -> RangeIterator<Section> {
        return RangeIterator(range: 0 ..< numberOfSections) { self[sectionAt: $0] }
    }
}
