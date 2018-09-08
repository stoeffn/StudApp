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

@objc(User)
public final class User: NSManagedObject, CDCreatable, CDIdentifiable, CDSortable {

    // MARK: Identification

    public static let entity = ObjectIdentifier.Entites.user

    @NSManaged public var id: String

    @NSManaged public var username: String

    @NSManaged public var givenName: String

    @NSManaged public var familyName: String

    @NSManaged public var namePrefix: String?

    @NSManaged public var nameSuffix: String?

    // MARK: Specifying Location

    @NSManaged public var organization: Organization

    // MARK: Managing Metadata

    @NSManaged public var pictureModifiedAt: Date?

    @NSManaged public var state: UserState

    // MARK: Managing Belongings

    @NSManaged public var authoredCourses: Set<Course>

    @NSManaged public var createdAnnouncements: Set<Announcement>

    @NSManaged public var downloads: Set<File>

    @NSManaged public var events: Set<Event>

    @NSManaged public var lecturedCourses: Set<Course>

    @NSManaged public var ownedFiles: Set<File>

    // MARK: - Life Cycle

    public required convenience init(createIn context: NSManagedObjectContext) {
        self.init(context: context)
        state = UserState(createIn: context)
    }

    // MARK: - Sorting

    static let defaultSortDescriptors = [
        NSSortDescriptor(key: "username", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:))),
    ]

    // MARK: - Describing

    public override var description: String {
        return "<User id: \(id), username: \(username)>"
    }
}

// MARK: - Core Data Operations

extension User {
    static var currentUserFromDefaults: User? {
        guard Targets.current != .tests else { return nil }

        let coreDataService = ServiceContainer.default[CoreDataService.self]
        guard let user = try? fetch(byId: UserDefaults.studKit.userId, in: coreDataService.viewContext) else { return nil }
        return user
    }

    public internal(set) static var current: User? = currentUserFromDefaults {
        didSet {
            guard current != oldValue else { return }

            UserDefaults.studKit.userId = current?.id
            NotificationCenter.default.post(name: .currentUserDidChange, object: nil)
        }
    }

    public func authoredCoursesFetchRequest(in semester: Semester? = nil, includingHidden: Bool = false) -> NSFetchRequest<Course> {
        var predicates = [NSPredicate(format: "%@ IN authors", self)]

        if let semester = semester {
            predicates.append(NSPredicate(format: "%@ IN semesters", semester))
        }

        if !includingHidden {
            predicates.append(NSPredicate(format: "isHidden == NO"))
        }

        let predicate = NSCompoundPredicate(type: .and, subpredicates: predicates)
        return Course.fetchRequest(predicate: predicate, sortDescriptors: Course.defaultSortDescriptors,
                                   relationshipKeyPathsForPrefetching: ["state"])
    }

    public func downloadsPredicate(forSearchTerm searchTerm: String? = nil) -> NSPredicate {
        let downloadedPredicate = NSPredicate(format: "%@ IN downloadedBy", self)

        guard let searchTerm = searchTerm, !searchTerm.isEmpty else { return downloadedPredicate }

        let trimmedSearchTerm = searchTerm.trimmingCharacters(in: .whitespacesAndNewlines)

        let similarTitlePredicate = NSPredicate(format: "name CONTAINS[cd] %@", trimmedSearchTerm)
        let similarCourseTitlePredicate = NSPredicate(format: "course.title CONTAINS[cd] %@", trimmedSearchTerm)
        let similarOwnerFamilyNamePredicate = NSPredicate(format: "owner.familyName CONTAINS[cd] %@", trimmedSearchTerm)
        let similarOwnerGivenNamePredicate = NSPredicate(format: "owner.givenName CONTAINS[cd] %@", trimmedSearchTerm)

        return NSCompoundPredicate(type: .and, subpredicates: [
            downloadedPredicate,
            NSCompoundPredicate(type: .or, subpredicates: [
                similarTitlePredicate, similarCourseTitlePredicate, similarOwnerFamilyNamePredicate,
                similarOwnerGivenNamePredicate,
            ]),
        ])
    }

    public var downloadsFetchRequest: NSFetchRequest<File> {
        let sortDescriptors = [
            NSSortDescriptor(keyPath: \File.course.groupId, ascending: true),
            NSSortDescriptor(key: "course.title", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:))),
        ] + File.defaultSortDescriptors
        return File.fetchRequest(predicate: downloadsPredicate(), sortDescriptors: sortDescriptors,
                                 relationshipKeyPathsForPrefetching: ["state"])
    }
}

// MARK: - Events Container

extension User: EventsContaining {
    public var title: String {
        return username
    }

    public var eventsPredicate: NSPredicate {
        return NSPredicate(format: "%@ IN users", self)
    }
}

// MARK: - Utilities

public extension User {
    public var nameComponents: PersonNameComponents {
        var components = PersonNameComponents()
        components.givenName = givenName
        components.familyName = familyName
        components.namePrefix = namePrefix
        components.nameSuffix = nameSuffix
        return components
    }
}

// MARK: - Notification

public extension Notification.Name {
    public static let currentUserDidChange = Notification.Name(rawValue: "currentUserDidChange")
}
