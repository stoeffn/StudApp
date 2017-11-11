//
//  DataSourceSectionDelegate.swift
//  RemonderKit
//
//  Created by Steffen Ryll on 19.09.17.
//  Copyright © 2017 Remonder. All rights reserved.
//

public protocol DataSourceSectionDelegate: class {
    func dataWillChange<Section: DataSourceSection>(in section: Section)

    func dataDidChange<Section: DataSourceSection>(in section: Section)

    func data<Section: DataSourceSection>(changedIn row: Section.Row, at index: Int,
                                          change: DataChange<Section.Row, Int>, in section: Section)
}
