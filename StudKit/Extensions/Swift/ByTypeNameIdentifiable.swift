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

/// Something that can be identified by its non-generic type name, e.g. a database table or table view cell.
public protocol ByTypeNameIdentifiable {}

public extension ByTypeNameIdentifiable {
    /// This object's type name without generic type information, e.g. `Set` instead of `Set<Int>`.
    public static var typeIdentifier: String {
        let typeName = String(describing: Self.self)
        return typeName
            .components(separatedBy: "<")
            .first ?? typeName
    }
}
