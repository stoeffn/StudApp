//
//  DataSourceDelegate.swift
//  StudKit
//
//  Created by Steffen Ryll on 19.09.17.
//  Copyright © 2017 Remonder. All rights reserved.
//

public protocol DataSourceDelegate: class {
    func dataWillChange<Source: DataSource>(in source: Source)

    func dataDidChange<Source: DataSource>(in source: Source)

    func data<Source: DataSource>(changedIn row: Source.Row, at index: IndexPath,
                                  change: DataChange<Source.Row, IndexPath>, in source: Source)

    func data<Source: DataSource>(changedIn section: Source.Section, at index: Int,
                                  change: DataChange<Source.Section, Int>, in source: Source)
}

public extension DataSourceDelegate {
    func dataWillChange<Source: DataSource>(in _: Source) {}

    func dataDidChange<Source: DataSource>(in _: Source) {}

    func data<Source: DataSource>(changedIn _: Source.Row, at _: IndexPath, change _: DataChange<Source.Row, IndexPath>,
                                  in _: Source) {}

    func data<Source: DataSource>(changedIn _: Source.Section, at _: Int, change _: DataChange<Source.Section, Int>,
                                  in _: Source) {}
}
