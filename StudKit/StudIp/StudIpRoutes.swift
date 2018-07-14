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

/// Selection of API routes exposed by the Stud.IP API.
public enum StudIpRoutes: ApiRoutes {
    /// Returns a collection of unexpired announcements for the course with the id given.
    case announcementsInCourse(withId: String)

    /// Returns the current user.
    case currentUser

    /// Returns all courses that a user with the given id is enrolled in.
    case courses(forUserId: String)

    /// Deletes a hook.
    case deleteHook(withId: String)

    /// Returns information on what routes are available.
    case discovery

    /// Returns the contents of a file with the given id. If `externalUrl` is not `nil`, this URL will be used for downloading
    /// the file instead of using the default _Stud.IP_ file content API.
    case fileContents(forFileId: String, externalUrl: URL?)

    /// Returns a folder along with its first-level children.
    case folder(withId: String)

    /// Returns events for the user given within the next two weeks.
    case eventsForUser(withId: String)

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

    /// Updates the hook given or creates it when it doesn't exist.
    case updateOrCreateHook(Hook)

    case messagesInCourse(withId: String)

    case sendMessageToCourse(withId: String, message: String)

    var identifier: String {
        switch self {
        case .announcementsInCourse: return "/course/:course_id/news"
        case .currentUser: return "/user"
        case .courses: return "/user/:user_id"
        case .deleteHook: return "/hooks/:hook_id"
        case .discovery: return "/discovery"
        case .fileContents: return "/file/:file_ref_id/download"
        case .folder: return "/folder/:folder_id"
        case .eventsForUser: return "/user/:user_id/events"
        case .eventsInCourse: return "/course/:course_id/events"
        case .profilePicture: return "/user/:user_id/picture"
        case .rootFolderForCourse: return "/course/:course_id/top_folder"
        case .semesters: return "/semester/:semester_id"
        case .setGroupForCourse: return "/user/:user_id/courses/:course_id"
        case .updateOrCreateHook: return "/hooks"
        case .messagesInCourse: return ""
        case .sendMessageToCourse: return ""
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
        case let .deleteHook(hookId):
            return "hooks/\(hookId)"
        case .discovery:
            return "discovery"
        case let .eventsForUser(userId):
            return "/user/\(userId)/events"
        case let .eventsInCourse(courseId):
            return "course/\(courseId)/events"
        case let .fileContents(fileId, _):
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
        case .updateOrCreateHook:
            return "hooks"
        case let .messagesInCourse(courseId):
            return "course/\(courseId)/blubber"
        case let .sendMessageToCourse(courseId, _):
            return "course/\(courseId)/blubber"
        }
    }

    var url: URL? {
        switch self {
        case let .fileContents(_, externalUrl):
            return externalUrl
        default:
            return nil
        }
    }

    var type: Decodable.Type? {
        switch self {
        case .announcementsInCourse: return CollectionResponse<AnnouncementResponse>.self
        case .currentUser: return UserResponse.self
        case .courses: return CollectionResponse<CourseResponse>.self
        case .deleteHook: return nil
        case .discovery: return DiscoveryResponse.self
        case .eventsForUser, .eventsInCourse: return CollectionResponse<EventResponse>.self
        case .fileContents: return nil
        case .folder: return FolderResponse.self
        case .profilePicture: return nil
        case .rootFolderForCourse: return FolderResponse.self
        case .semesters: return CollectionResponse<SemesterResponse>.self
        case .setGroupForCourse: return nil
        case .updateOrCreateHook: return Hook.self
        case .messagesInCourse: return CollectionResponse<Message>.self
        case .sendMessageToCourse: return nil
        }
    }

    var method: HttpMethods {
        switch self {
        case .announcementsInCourse, .courses, .currentUser, .discovery, .eventsForUser, .eventsInCourse, .folder,
             .fileContents, .profilePicture, .rootFolderForCourse, .semesters, .messagesInCourse:
            return .get
        case .deleteHook:
            return .delete
        case .setGroupForCourse:
            return .patch
        case .updateOrCreateHook, .sendMessageToCourse:
            return .post
        }
    }

    var contentType: String? {
        switch self {
        case .announcementsInCourse, .courses, .currentUser, .deleteHook, .discovery, .eventsForUser, .eventsInCourse, .folder,
             .fileContents, .profilePicture, .rootFolderForCourse, .semesters, .messagesInCourse:
            return nil
        case .setGroupForCourse, .updateOrCreateHook, .sendMessageToCourse:
            return "application/json"
        }
    }

    var body: Data? {
        switch self {
        case .announcementsInCourse, .courses, .currentUser, .deleteHook, .discovery, .eventsForUser, .eventsInCourse, .folder,
             .fileContents, .profilePicture, .rootFolderForCourse, .semesters, .messagesInCourse:
            return nil
        case let .setGroupForCourse(_, _, groupId):
            return "{\"group\": \(groupId)}".data(using: .utf8)
        case let .sendMessageToCourse(courseId, text):
            return "{\"content\": \"\(text)\"}".data(using: .utf8)
        case let .updateOrCreateHook(hook):
            return try? ServiceContainer.default[JSONEncoder.self].encode(hook)
        }
    }
}
