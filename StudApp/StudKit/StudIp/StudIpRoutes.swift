//
//  StudIpRoutes.swift
//  StudKit
//
//  Created by Steffen Ryll on 22.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

/// Selection of API routes exposed by the Stud.IP API.
public enum StudIpRoutes: ApiRoutes {
    /// Contains information on available routes and access restrictions.
    case discovery

    /// Returns all semesters, usually starting about ten years in the past and ending one year in the
    /// future.
    case semesters

    /// Returns all courses that a user with the given id is enrolled in.
    case courses(forUserId: String)

    /// Returns the complete file tree for a course with the given id, including all folder and document
    /// meta data.
    case filesInCourse(withId: String)

    /// Returns meta data for a single file with first-level children in case of a folder.
    case file(withId: String)

    /// Returns the contents of a file with the given id.
    case fileContents(forFileId: String)

    /// Returns the profile picture at the URL given.
    case profilePicture(URL)

    var path: String {
        switch self {
        case .discovery:
            return "discovery"
        case .semesters:
            return "semesters"
        case let .courses(userId):
            return "user/\(userId)/courses"
        case let .filesInCourse(courseId):
            return "course/\(courseId)/files"
        case let .file(folderId):
            return "file/\(folderId)"
        case let .fileContents(fileId):
            return "file/\(fileId)/content"
        case let .profilePicture(url):
            return url.path
        }
    }

    var type: Decodable.Type? {
        switch self {
        case .discovery: return [String: [String: String]].self
        case .semesters: return CollectionResponse<SemesterResponse>.self
        case .courses: return CollectionResponse<CourseResponse>.self
        case .filesInCourse: return CollectionResponse<FileResponse>.self
        case .file: return FileResponse.self
        case .fileContents, .profilePicture: return nil
        }
    }

    var expiresAfter: TimeInterval {
        switch self {
        case .discovery: return 0
        case .courses, .filesInCourse, .file, .fileContents: return 60
        case .semesters, .profilePicture: return 60 * 60
        }
    }
}
