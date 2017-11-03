//
//  DataSourceDelegate.swift
//  RemonderKit
//
//  Created by Steffen Ryll on 19.09.17.
//  Copyright © 2017 Remonder. All rights reserved.
//

public protocol DataSourceDelegate : class {
    func dataWillChange<Source: DataSource>(in source: Source)

    func dataDidChange<Source: DataSource>(in source: Source)

    func data<Source: DataSource>(changedIn row: Source.Row, at index: IndexPath,
                                  change: DataChange<Source.Row, IndexPath>, in source: Source)

    func data<Source: DataSource>(changedIn section: Source.Section, at index: Int,
                                  change: DataChange<Source.Section, Int>, in source: Source)
}
