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

public protocol DataSourceSectionDelegate: AnyObject {
    func dataWillChange<Section: DataSourceSection>(in section: Section)

    func dataDidChange<Section: DataSourceSection>(in section: Section)

    func data<Section: DataSourceSection>(changedIn row: Section.Row, at index: Int, change: DataChange<Section.Row, Int>,
                                          in section: Section)
}

// MARK: - Default Implementation

public extension DataSourceSectionDelegate {
    func dataWillChange<Section: DataSourceSection>(in _: Section) {}

    func dataDidChange<Section: DataSourceSection>(in _: Section) {}

    func data<Section: DataSourceSection>(changedIn _: Section.Row, at _: Int, change _: DataChange<Section.Row, Int>,
                                          in _: Section?) {}
}
