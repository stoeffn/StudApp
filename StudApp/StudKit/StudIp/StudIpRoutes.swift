//
//  StudIpRoutes.swift
//  StudKit
//
//  Created by Steffen Ryll on 22.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public enum StudIpRoutes : ApiRoutes {
    case discovery
    
    case semesters

    case courses(forUserId: String)

    case files(forCourseId: String)

    case fileContents(id: String)

    case profilePicture(URL)

    var path: String {
        switch self {
        case .discovery:
            return "discovery"
        case .semesters:
            return "semesters"
        case .courses(let userId):
            return "user/\(userId)/courses"
        case .files(let courseId):
            return "course/\(courseId)/files"
        case .fileContents(let fileId):
            return "file/\(fileId)/content"
        case .profilePicture(let url):
            return url.path
        }
    }

    var type: Decodable.Type? {
        switch self {
        case .discovery: return [String: [String: String]].self
        case .semesters: return CollectionResponse<SemesterModel>.self
        case .courses: return CollectionResponse<CourseModel>.self
        case .files: return CollectionResponse<FileModel>.self
        case .fileContents, .profilePicture: return nil
        }
    }
}
