//
//  StudIpRoutes.swift
//  StudKit
//
//  Created by Steffen Ryll on 22.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

/// Selection of API routes exposed by the Stud.IP API.
public enum StudIpRoutes: ApiRoutes {
    /// Returns a collection of unexpired announcements for the course with the id given.
    case announcementsInCourse(withId: String)

    /// Returns the current user.
    case currentUser

    /// Returns all courses that a user with the given id is enrolled in.
    case courses(forUserId: String)

    /// Returns information on what routes are available.
    case discovery

    /// Returns the contents of a file with the given id.
    case fileContents(forFileId: String)

    /// Returns a folder along with its first-level children.
    case folder(withId: String)

    /// Returns a collection of all events for a course.
    case eventsInCourse(withId: String)

    /// Returns the profile picture at the URL given.
    case profilePicture(URL)

    /// Returns the root folder along with its first-level children.
    case rootFolderForCourse(withId: String)

    /// Returns all semesters, usually starting about ten years in the past and ending one year in the
    /// future.
    case semesters

    /// Sets a course's group id specific to the user given.
    case setGroupForCourse(withId: String, andUserWithId: String, groupId: Int)

    var identifier: String {
        switch self {
        case .announcementsInCourse: return "/course/:course_id/news"
        case .currentUser: return "/user"
        case .courses: return "/user/:user_id"
        case .discovery: return "/discovery"
        case .fileContents: return "/file/:file_ref_id/download"
        case .folder: return "/folder/:folder_id"
        case .eventsInCourse: return "/course/:course_id/events"
        case .profilePicture: return "/user/:user_id/picture"
        case .rootFolderForCourse: return "/course/:course_id/top_folder"
        case .semesters: return "/semester/:semester_id"
        case .setGroupForCourse: return "/user/:user_id/courses/:course_id"
        }
    }

    var path: String {
        switch self {
        case let .announcementsInCourse(courseId):
            return "course/\(courseId)/news"
        case .currentUser:
            return "user"
        case let .courses(userId):
            return "user/\(userId)/courses"
        case .discovery:
            return "discovery"
        case let .eventsInCourse(courseId):
            return "course/\(courseId)/events"
        case let .fileContents(fileId):
            return "file/\(fileId)/download"
        case let .folder(folderId):
            return "folder/\(folderId)"
        case let .profilePicture(url):
            return url.path
        case let .rootFolderForCourse(courseId):
            return "course/\(courseId)/top_folder"
        case .semesters:
            return "semesters"
        case let .setGroupForCourse(withId: courseId, andUserWithId: userId, _):
            return "user/\(userId)/courses/\(courseId)"
        }
    }

    var type: Decodable.Type? {
        switch self {
        case .announcementsInCourse: return CollectionResponse<AnnouncementResponse>.self
        case .currentUser: return UserResponse.self
        case .courses: return CollectionResponse<CourseResponse>.self
        case .discovery: return DiscoveryResponse.self
        case .eventsInCourse: return CollectionResponse<EventResponse>.self
        case .fileContents: return nil
        case .folder: return FolderResponse.self
        case .profilePicture: return nil
        case .rootFolderForCourse: return FolderResponse.self
        case .semesters: return CollectionResponse<SemesterResponse>.self
        case .setGroupForCourse: return nil
        }
    }

    var method: HttpMethods {
        switch self {
        case .announcementsInCourse, .courses, .currentUser, .discovery, .eventsInCourse, .folder, .fileContents,
             .profilePicture, .rootFolderForCourse, .semesters:
            return .get
        case .setGroupForCourse:
            return .patch
        }
    }

    var contentType: String? {
        switch self {
        case .announcementsInCourse, .courses, .currentUser, .discovery, .eventsInCourse, .folder, .fileContents,
             .profilePicture, .rootFolderForCourse, .semesters:
            return nil
        case .setGroupForCourse:
            return "application/json"
        }
    }

    var body: Data? {
        switch self {
        case .announcementsInCourse, .courses, .currentUser, .discovery, .eventsInCourse, .folder, .fileContents,
             .profilePicture, .rootFolderForCourse, .semesters:
            return nil
        case let .setGroupForCourse(_, _, groupId):
            return "{\"group\": \(groupId)}".data(using: .utf8)
        }
    }

    var expiresAfter: TimeInterval {
        switch self {
        case .fileContents, .setGroupForCourse:
            return 0
        case .announcementsInCourse, .courses, .currentUser, .discovery, .folder, .rootFolderForCourse:
            return 60 * 5
        case .eventsInCourse, .profilePicture, .semesters:
            return 60 * 60
        }
    }
}
