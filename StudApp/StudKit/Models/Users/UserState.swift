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

import CoreData

@objc(UserState)
public final class UserState: NSManagedObject, CDCreatable, CDSortable {

    // MARK: Specifying Location

    @NSManaged public var user: User

    // MARK: Tracking Usage

    @NSManaged public var authoredCoursesUpdatedAt: Date?

    // MARK: - Sorting

    static let defaultSortDescriptors = [
        NSSortDescriptor(keyPath: \UserState.user.username, ascending: true),
    ]

    // MARK: - Describing

    public override var description: String {
        return "<UserState: \(user)>"
    }
}
