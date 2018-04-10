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

    // TODO: Remove and make state non-optional
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)

        if let context = context, primitiveValue(forKey: "state") == nil {
            state = UserState(createIn: context)
        }
    }

    public required convenience init(createIn context: NSManagedObjectContext) {
        self.init(context: context)
        state = UserState(createIn: context)
    }

    // MARK: - Sorting

    static let defaultSortDescriptors = [
        NSSortDescriptor(keyPath: \User.username, ascending: true),
    ]

    // MARK: - Describing

    public override var description: String {
        return "<User id: \(id), username: \(username)>"
    }
}

// MARK: - Core Data Operations

extension User {
    private static var currentUserFromDefaults: User? {
        guard Targets.current != .tests else { return nil }

        let storageService = ServiceContainer.default[StorageService.self]
        let coreDataService = ServiceContainer.default[CoreDataService.self]
        let currentUserId = storageService.defaults.string(forKey: UserDefaults.userIdKey)
        guard let user = try? fetch(byId: currentUserId, in: coreDataService.viewContext) else { return nil }
        return user
    }

    public internal(set) static var current: User? = currentUserFromDefaults {
        didSet {
            guard current != oldValue else { return }

            let storageService = ServiceContainer.default[StorageService.self]
            storageService.defaults.set(current?.id, forKey: UserDefaults.userIdKey)
            NotificationCenter.default.post(name: .currentUserDidChange, object: nil)
        }
    }

    public func authoredCoursesFetchRequest(in semester: Semester? = nil) -> NSFetchRequest<Course> {
        var predicates = [NSPredicate(format: "%@ IN authors", self)]
        if let semester = semester {
            predicates.append(NSPredicate(format: "%@ in semesters", semester))
        }
        let predicate = NSCompoundPredicate(type: .and, subpredicates: predicates)
        return Course.fetchRequest(predicate: predicate, sortDescriptors: Course.defaultSortDescriptors,
                                   relationshipKeyPathsForPrefetching: ["state"])
    }

    public func downloadsPredicate(forSearchTerm searchTerm: String? = nil) -> NSPredicate {
        let downloadedPredicate = NSPredicate(format: "%@ in downloadedBy", self)

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
            NSSortDescriptor(keyPath: \File.course.title, ascending: true),
        ] + File.defaultSortDescriptors
        return File.fetchRequest(predicate: downloadsPredicate(), sortDescriptors: sortDescriptors,
                                 relationshipKeyPathsForPrefetching: ["state"])
    }

    public var eventsFetchRequest: NSFetchRequest<Event> {
        let predicate = NSPredicate(format: "%@ IN users", self)
        return Event.fetchRequest(predicate: predicate, sortDescriptors: Event.defaultSortDescriptors)
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
