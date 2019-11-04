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

@objc(SemesterState)
public final class SemesterState: NSManagedObject, CDCreatable, CDSortable {
    // MARK: Specifying Location

    @NSManaged public var semester: Semester

    // MARK: Tracking Usage

    @NSManaged public var lastUsedAt: Date?

    // MARK: Managing Metadata

    @NSManaged public var favoriteRank: Int64

    @NSManaged public var tagData: Data?

    // MARK: Managing State

    @NSManaged public var isHidden: Bool

    @NSManaged public var isCollapsed: Bool

    // MARK: - Life Cycle

    public required convenience init(createIn context: NSManagedObjectContext) {
        self.init(context: context)

        #if !targetEnvironment(macCatalyst)
        favoriteRank = Int64(NSFileProviderFavoriteRankUnranked)
        #endif
    }

    // MARK: - Sorting

    static let defaultSortDescriptors = [
        NSSortDescriptor(keyPath: \SemesterState.semester.beginsAt, ascending: false),
    ]

    // MARK: - Describing

    public override var description: String {
        return "<SemesterState: \(semester)>"
    }
}
