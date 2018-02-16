//
//  StudIpRoutes.swift
//  StudKit
//
//  Created by Steffen Ryll on 22.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

/// Selection of API routes exposed by the Stud.IP API.
public enum StudIpRoutes: ApiRoutes {
    /// Returns all semesters, usually starting about ten years in the past and ending one year in the
    /// future.
    case semesters

    /// Returns all courses that a user with the given id is enrolled in.
    case courses(forUserId: String)

    /// Returns the root folder along with its first-level children.
    case rootFolderForCourse(withId: String)

    /// Returns a folder along with its first-level children.
    case folder(withId: String)

    /// Returns the contents of a file with the given id.
    case fileContents(forFileId: String)

    /// Returns a collection of unexpired announcements for the course with the id given.
    case announcementsInCourse(withId: String)

    /// Returns a collection of all events for a course.
    case eventsInCourse(withId: String)

    /// Returns the profile picture at the URL given.
    case profilePicture(URL)

    /// Returns the current user.
    case currentUser

    var path: String {
        switch self {
        case .semesters:
            return "semesters"
        case let .courses(userId):
            return "user/\(userId)/courses"
        case let .rootFolderForCourse(courseId):
            return "course/\(courseId)/top_folder"
        case let .folder(folderId):
            return "folder/\(folderId)"
        case let .fileContents(fileId):
            return "file/\(fileId)/download"
        case let .announcementsInCourse(courseId):
            return "course/\(courseId)/news"
        case let .eventsInCourse(courseId):
            return "course/\(courseId)/events"
        case let .profilePicture(url):
            return url.path
        case .currentUser:
            return "user"
        }
    }

    var type: Decodable.Type? {
        switch self {
        case .semesters: return CollectionResponse<SemesterResponse>.self
        case .courses: return CollectionResponse<CourseResponse>.self
        case .rootFolderForCourse: return FolderResponse.self
        case .folder: return FolderResponse.self
        case .fileContents, .profilePicture: return nil
        case .announcementsInCourse: return CollectionResponse<AnnouncementResponse>.self
        case .eventsInCourse: return CollectionResponse<EventResponse>.self
        case .currentUser: return UserResponse.self
        }
    }

    var expiresAfter: TimeInterval {
        switch self {
        case .fileContents:
            return 0
        case .courses, .rootFolderForCourse, .folder, .announcementsInCourse, .currentUser:
            return 60
        case .semesters, .profilePicture, .eventsInCourse:
            return 60 * 60
        }
    }
}
