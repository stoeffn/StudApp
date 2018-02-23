//
//  DataSourceSectionDelegate.swift
//  StudKit
//
//  Created by Steffen Ryll on 19.09.17.
//  Copyright © 2017 Remonder. All rights reserved.
//

public protocol DataSourceSectionDelegate: class {
    func dataWillChange<Section: DataSourceSection>(in section: Section)

    func dataDidChange<Section: DataSourceSection>(in section: Section)

    func data<Section: DataSourceSection>(changedIn row: Section.Row, at index: Int, change: DataChange<Section.Row, Int>,
                                          in section: Section)
}

// MARK: - Default Implementation

public extension DataSourceSectionDelegate {
    public func dataWillChange<Section: DataSourceSection>(in _: Section) {}

    public func dataDidChange<Section: DataSourceSection>(in _: Section) {}

    public func data<Section: DataSourceSection>(changedIn _: Section.Row, at _: Int, change _: DataChange<Section.Row, Int>,
                                                 in _: Section?) {}
}
