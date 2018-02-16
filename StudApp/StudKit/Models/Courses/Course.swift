//
//  Course.swift
//  StudKit
//
//  Created by Steffen Ryll on 25.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import CoreSpotlight
import MobileCoreServices

/// Course that a user can attend, e.g. a university class.
///
/// Besides containing some metadata such as a title and location, each course is alse the root node of a file structure.
@objc(Course)
public final class Course: NSManagedObject, CDCreatable, CDIdentifiable, CDUpdatable, CDSortable {
    public static var entity = ObjectIdentifier.Entites.course

    @NSManaged public var id: String

    /// Course number internal to Stud.IP that can also be used for identifying a course.
    @NSManaged public var number: String?

    @NSManaged public var title: String

    @NSManaged public var subtitle: String?

    /// Short description of the course and/or summary of its contents.
    @NSManaged public var summary: String?

    /// Describes where this course is held.
    @NSManaged public var location: String?

    @NSManaged public var lecturers: Set<User>

    @NSManaged public var rootFolder: File

    /// As a course can span multiple semesters, there is a set of semesters. However, most courses exist in one semester only.
    /// It is also important to know that—if contained in semesters `A` and `C`—a course should also be contained in `B`.
    @NSManaged public var semesters: Set<Semester>

    @NSManaged public var announcements: Set<Announcement>

    @NSManaged public var events: Set<Event>

    @NSManaged public var state: CourseState

    // MARK: - Life Cycle

    public required convenience init(createIn context: NSManagedObjectContext) {
        self.init(context: context)
        state = CourseState(createIn: context)
        rootFolder = File(createIn: context)
        rootFolder.title = title
    }

    // MARK: - Sorting

    static let defaultSortDescriptors = [
        NSSortDescriptor(keyPath: \Course.title, ascending: true),
    ]
}

// MARK: - Core Data Operations

extension Course {
    /// Request for fetching all announcements for this course that are not expired.
    public var unexpiredAnnouncementsFetchRequest: NSFetchRequest<Announcement> {
        let predicate = NSPredicate(format: "%@ IN courses AND expiresAt >= %@", self, Date() as CVarArg)
        return Announcement.fetchRequest(predicate: predicate, sortDescriptors: Announcement.defaultSortDescriptors)
    }

    public var eventsFetchRequest: NSFetchRequest<Event> {
        let predicate = NSPredicate(format: "course == %@", self)
        return Event.fetchRequest(predicate: predicate, sortDescriptors: Event.defaultSortDescriptors)
    }
}

// MARK: - Core Spotlight and Activity Tracking

extension Course {
    public var keywords: Set<String> {
        let courseKeyWords = [number].flatMap { $0 }.set
        let lecturersKeywords = lecturers.flatMap { [$0.givenName, $0.familyName] }.set
        let semestersKeywords = semesters.map { $0.title }.set
        return courseKeyWords.union(lecturersKeywords).union(semestersKeywords)
    }

    public var searchableItemAttributes: CSSearchableItemAttributeSet {
        let attributes = CSSearchableItemAttributeSet(itemContentType: kUTTypeFolder as String)

        attributes.displayName = title
        attributes.keywords = keywords.array
        attributes.relatedUniqueIdentifier = objectIdentifier.rawValue
        attributes.title = title

        attributes.contentDescription = summary

        return attributes
    }

    public var searchableItem: CSSearchableItem {
        return CSSearchableItem(uniqueIdentifier: objectIdentifier.rawValue, domainIdentifier: Course.entity.rawValue,
                                attributeSet: searchableItemAttributes)
    }

    public var userActivity: NSUserActivity {
        let activity = NSUserActivity(activityType: UserActivities.courseIdentifier)
        activity.isEligibleForHandoff = true
        activity.isEligibleForSearch = true
        activity.title = title
        activity.webpageURL = url
        activity.contentAttributeSet = searchableItemAttributes
        activity.keywords = keywords
        activity.objectIdentifier = objectIdentifier
        return activity
    }
}
