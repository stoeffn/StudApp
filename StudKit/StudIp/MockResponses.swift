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

struct MockResponses {
    private let now = Date()

    // MARK: - Organizations

    private(set) lazy var organization = OrganizationRecord(id: "O0")

    // MARK: - Semesters

    private(set) lazy var semesters = [
        SemesterResponse(id: "S0", title: "Winter 2016/17".localized, beginsAt: Date(timeIntervalSince1970: 1_475_338_860),
                         endsAt: Date(timeIntervalSince1970: 1_488_388_860)),
        SemesterResponse(id: "S1", title: "Summer 2017".localized, beginsAt: Date(timeIntervalSince1970: 1_491_004_800),
                         endsAt: Date(timeIntervalSince1970: 1_504_224_000)),
        SemesterResponse(id: "S2", title: "Winter 2017/18".localized, beginsAt: Date(timeIntervalSince1970: 1_504_282_860),
                         endsAt: Date(timeIntervalSince1970: 1_519_924_860)),
        SemesterResponse(id: "S3", title: "Summer 2018".localized, beginsAt: Date(timeIntervalSince1970: 1_522_540_800),
                         endsAt: Date(timeIntervalSince1970: 1_535_760_000)),
    ]

    // MARK: - Users

    private(set) lazy var currentUser = UserResponse(id: "U0", username: "murphy", givenName: "Murphy", familyName: "Cooper")

    private(set) lazy var theCount = UserResponse(id: "U1", username: "theCount".localized, givenName: "Count".localized,
                                                  familyName: "von Count".localized)

    private(set) lazy var professorProton = UserResponse(id: "U2", username: "proton", givenName: "Professor", familyName: "Proton")

    private(set) lazy var langdon = UserResponse(id: "U3", username: "langdon", givenName: "Robert", familyName: "Langdon")

    private(set) lazy var tesla = UserResponse(id: "U4", username: "tesla", givenName: "Nikola", familyName: "Tesla")

    private(set) lazy var cooper = UserResponse(id: "U5", username: "coop", givenName: "Joseph", familyName: "Cooper")

    // MARK: - Courses

    private let programmingCourseSummary = [
        "In this course, you will learn the basics of computer programming.".localized,
        "",
        "Please refer to https://google.com/ if you have any questions.".localized
    ].joined(separator: "\n")

    private(set) lazy var courses = [
        CourseResponse(id: "C0", number: "1.00000000001", title: "Numerical Analysis".localized,
                       subtitle: "Optimizing Algorithms for Computers".localized, location: "Bielefeld Room".localized,
                       groupId: 1, lecturers: [theCount], beginSemesterId: "S3", endSemesterId: "S3"),
        CourseResponse(id: "C1", number: "3.14", title: "Linear Algebra I".localized,
                       subtitle: "Vectors and Stuff".localized, location: "Hugo Kulka Room".localized,
                       groupId: 1, lecturers: [cooper, theCount], beginSemesterId: "S2", endSemesterId: "S2"),
        CourseResponse(id: "C2", number: "3.14", title: "Linear Algebra II".localized,
                       subtitle: "Vectors and Stuff".localized, location: "Hugo Kulka Room".localized,
                       groupId: 1, lecturers: [cooper, theCount], beginSemesterId: "S3", endSemesterId: "S3"),
        CourseResponse(id: "C3", number: "42", title: "Computer Architecture".localized,
                       location: "Multimedia Room".localized, summary: "In this lecture, you will learn how to…",
                       groupId: 3, lecturers: [professorProton], beginSemesterId: "S2", endSemesterId: "S2"),
        CourseResponse(id: "C4", number: nil, title: "Theoretical Stud.IP Science".localized,
                       groupId: 4, lecturers: [professorProton], beginSemesterId: "S3", endSemesterId: "S3"),
        CourseResponse(id: "C5", number: nil, title: "Data Science 101".localized,
                       groupId: 4, lecturers: [tesla], beginSemesterId: "S3", endSemesterId: "S3"),
        CourseResponse(id: "C6", number: nil, title: "StudApp Feedback".localized,
                       groupId: 5, lecturers: [tesla], beginSemesterId: "S0", endSemesterId: "S3"),
        CourseResponse(id: "C7", number: "10011", title: "Coding Crash Course".localized,
                       subtitle: "Telling the Computer What to Do".localized, location: "Basement".localized,
                       summary: programmingCourseSummary, groupId: 2, lecturers: [langdon], beginSemesterId: "S3", endSemesterId: "S3"),
    ]

    // MARK: - Files

    private(set) lazy var codingCourseFolders = [
        FolderResponse(id: "F0", userId: langdon.id, name: "Slides".localized, createdAt: now - 60 * 60 * 24,
                       modifiedAt: now - 60 * 60 * 24),
        FolderResponse(id: "F1", userId: tesla.id, name: "Exercises".localized, createdAt: now - 60 * 60 * 24 * 5,
                       modifiedAt: now - 60 * 60 * 4),
        FolderResponse(id: "F2", userId: tesla.id, name: "Solutions".localized, createdAt: now - 60 * 60 * 24 * 5,
                       modifiedAt: now - 60 * 60 * 36)
    ]

    private(set) lazy var codingCourseDocuments = [
        DocumentResponse(id: "F3", location: .studIp, userId: tesla.id, name: "Organization.pdf".localized,
                         createdAt: now - 60 * 60 * 24 * 20, modifiedAt: now - 60 * 60 * 24 * 20, size: 1024 * 42, downloadCount: 96),
        DocumentResponse(id: "F4", location: .external, externalUrl: URL(string: "https://dropbox.com/test.mp4"), userId: langdon.id,
                         name: "Installing Swift.mp4".localized, createdAt: now - 60 * 60 * 24 * 19,
                         modifiedAt: now - 60 * 60 * 24 * 19, size: 1024 * 1024 * 67)
    ]

    // MARK: - Events

    private(set) lazy var events = [
        EventResponse(id: "E0", courseId: "C7", startsAt: now + 60 * 60 * 12, endsAt: now + 60 * 60 * 13.5,
                      location: "Basement".localized),
        EventResponse(id: "E1", courseId: "C7", startsAt: now + 60 * 60 * 48, endsAt: now + 60 * 60 * 49.5,
                      location: "Basement".localized),
    ]

    // MARK: - Inserting Data

    mutating func insert(into context: NSManagedObjectContext) throws {
        let organization = try self.organization.coreDataObject(in: context)

        let user = try currentUser.coreDataObject(organization: organization, in: context)
        user.state.authoredCoursesUpdatedAt = now
        user.state.eventsUpdatedAt = now
        User.current = user

        try semesters.forEach { response in
            let semester = try response.coreDataObject(organization: organization, in: context)
            semester.state.isHidden = false
            semester.state.isCollapsed = true
        }

        try courses.forEach { response in
            let course = try response.coreDataObject(organization: organization, author: user, in: context)
            course.state.announcementsUpdatedAt = now
            course.state.childFilesUpdatedAt = now
            course.state.eventsUpdatedAt = now
        }

        let codingCourse = try Course.fetch(byId: "C7", in: context)!

        try codingCourseFolders.forEach { response in
            try response.coreDataObject(course: codingCourse, in: context)
        }

        try codingCourseDocuments.forEach { response in
            try response.coreDataObject(course: codingCourse, in: context)
        }

        try events.forEach { response in
            try response.coreDataObject(user: user, in: context)
        }
    }
}
