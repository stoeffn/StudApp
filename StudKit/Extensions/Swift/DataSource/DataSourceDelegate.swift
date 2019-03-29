//
//  StudApp—Stud.IP to Go
//  Copyright © 2018, Steffen Ryll
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see http://www.gnu.org/licenses/.
//

public protocol DataSourceDelegate: AnyObject {
    func dataWillChange<Source: DataSource>(in source: Source)

    func dataDidChange<Source: DataSource>(in source: Source)

    func data<Source: DataSource>(changedIn row: Source.Row, at index: IndexPath, change: DataChange<Source.Row, IndexPath>,
                                  in source: Source)

    func data<Source: DataSource>(changedIn section: Source.Section?, at index: Int, change: DataChange<Source.Section?, Int>,
                                  in source: Source)
}

// MARK: - Default Implementation

public extension DataSourceDelegate {
    func dataWillChange<Source: DataSource>(in _: Source) {}

    func dataDidChange<Source: DataSource>(in _: Source) {}

    func data<Source: DataSource>(changedIn _: Source.Row, at _: IndexPath, change _: DataChange<Source.Row, IndexPath>,
                                  in _: Source) {}

    func data<Source: DataSource>(changedIn _: Source.Section?, at _: Int, change _: DataChange<Source.Section?, Int>,
                                  in _: Source) {}
}
