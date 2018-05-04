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
    private lazy var today = now.startOfDay
    private lazy var minute: TimeInterval = 60
    private lazy var hour: TimeInterval = minute * 60
    private lazy var day: TimeInterval = hour * 24
    private lazy var week: TimeInterval = day * 7

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
        "Please refer to https://google.com/ if you have any questions.".localized,
    ].joined(separator: "\n")

    private(set) lazy var courses = [
        CourseResponse(id: "C0", number: "1.00000000001", title: "Numerical Analysis".localized,
                       subtitle: "Optimizing Algorithms for Computers".localized, location: "Main Building\nBielefeld Room".localized,
                       groupId: 1, lecturers: [theCount], beginSemesterId: "S3", endSemesterId: "S3"),
        CourseResponse(id: "C1", number: "3.14", title: "Linear Algebra I".localized,
                       subtitle: "Vectors and Stuff".localized, location: "Main Building\nHugo Kulka Room".localized,
                       groupId: 1, lecturers: [cooper, theCount], beginSemesterId: "S2", endSemesterId: "S2"),
        CourseResponse(id: "C2", number: "3.14", title: "Linear Algebra II".localized,
                       subtitle: "Vectors and Stuff".localized, location: "Main Building\nHugo Kulka Room".localized,
                       groupId: 1, lecturers: [cooper, theCount], beginSemesterId: "S3", endSemesterId: "S3"),
        CourseResponse(id: "C3", number: "42", title: "Computer Architecture".localized,
                       location: "Building 42\nMultimedia Room".localized, summary: "In this lecture, you will learn how to…",
                       groupId: 3, lecturers: [professorProton], beginSemesterId: "S2", endSemesterId: "S2"),
        CourseResponse(id: "C4", number: nil, title: "Theoretical Stud.IP Science".localized,
                       groupId: 4, lecturers: [professorProton], beginSemesterId: "S3", endSemesterId: "S3"),
        CourseResponse(id: "C5", number: nil, title: "Data Science 101".localized,
                       groupId: 4, lecturers: [tesla], beginSemesterId: "S3", endSemesterId: "S3"),
        CourseResponse(id: "C6", number: nil, title: "StudApp Feedback".localized,
                       groupId: 5, lecturers: [tesla], beginSemesterId: "S0", endSemesterId: "S3"),
        CourseResponse(id: "C7", number: "10011", title: "Coding Crash Course".localized,
                       subtitle: "Telling the Computer What to Do".localized, location: "Main Building\nBasement".localized,
                       summary: programmingCourseSummary, groupId: 2, lecturers: [langdon], beginSemesterId: "S3", endSemesterId: "S3"),
    ]

    // MARK: - Announcements

    private(set) lazy var announcements = [
        AnnouncementResponse(id: "A0", courseIds: ["C7"], userId: langdon.id, createdAt: today - day * 3, modifiedAt: today - day * 3,
                             expiresAfter: week, title: "Remember to Bring Your Laptops!".localized),
    ]

    // MARK: - Files

    private(set) lazy var codingCourseFolders = [
        FolderResponse(id: "F0", userId: langdon.id, name: "Slides".localized, createdAt: now - week, modifiedAt: now - day),
        FolderResponse(id: "F1", userId: tesla.id, name: "Exercises".localized, createdAt: now - hour * 5, modifiedAt: now - hour * 4),
        FolderResponse(id: "F2", userId: tesla.id, name: "Solutions".localized, createdAt: now - week, modifiedAt: now - hour * 8),
    ]

    private(set) lazy var codingCourseDocuments = [
        DocumentResponse(id: "F3", location: .studIp, userId: tesla.id, name: "Organization.pdf".localized,
                         createdAt: now - day * 20, modifiedAt: now - day * 20, size: 1024 * 42, downloadCount: 96),
        DocumentResponse(id: "F4", location: .external, externalUrl: URL(string: "https://dropbox.com/test.mp4"), userId: langdon.id,
                         name: "Installing Swift.mp4".localized, createdAt: now - day * 19, modifiedAt: now - day * 19,
                         size: 1024 * 1024 * 67),
        DocumentResponse(id: "F5", location: .website, externalUrl: URL(string: "https://www.apple.com/swift/playgrounds/"),
                         userId: langdon.id, name: "How to Use Swift Playgrounds".localized, mimeType: "application/octet-stream",
                         createdAt: now - day * 18, modifiedAt: now - day * 18),
    ]

    private(set) lazy var numericalAnalysisCourseDocuments = [
        DocumentResponse(id: "F6", location: .studIp, userId: cooper.id, name: "Exercise 0.pdf".localized,
                         createdAt: now - day * 23, modifiedAt: now - day * 23, size: 1024 * 40, downloadCount: 345),
        DocumentResponse(id: "F7", location: .studIp, userId: cooper.id, name: "Exercise 1.pdf".localized,
                         createdAt: now - day * 16, modifiedAt: now - day * 16, size: 1024 * 45, downloadCount: 134),
        DocumentResponse(id: "F8", location: .studIp, userId: cooper.id, name: "Exercise 2.pdf".localized,
                         createdAt: now - day * 8, modifiedAt: now - day * 8, size: 1024 * 78, downloadCount: 96),
        DocumentResponse(id: "F9", location: .studIp, userId: cooper.id, name: "Exercise 3.pdf".localized,
                         createdAt: now - day, modifiedAt: now - day, size: 1024 * 124, downloadCount: 23),
    ]

    private(set) lazy var dataScienceCourseDocuments = [
        DocumentResponse(id: "F10", location: .studIp, userId: theCount.id, name: "BigData.csv".localized,
                         createdAt: now - hour * 8, modifiedAt: now - hour * 8, size: 96, downloadCount: 512),
        DocumentResponse(id: "F11", location: .studIp, userId: theCount.id, name: "Slides.pdf".localized,
                         createdAt: now - day * 16, modifiedAt: now - day * 16, size: 1024 * 128, downloadCount: 256),
    ]

    // MARK: - Events

    private(set) lazy var events = [
        EventResponse(id: "E0", title: "What can for loops do for me?".localized, courseId: "C7", startsAt: today + hour * 12,
                      endsAt: today + hour * 13.5, location: "Main Building\nBasement".localized),
        EventResponse(id: "E1", title: "Data Preprocessing".localized, courseId: "C5", startsAt: today + hour * 14,
                      endsAt: today + hour * 15, location: "Building 42\nMultimedia Room".localized),
        EventResponse(id: "E2", title: "Group 0".localized, courseId: "C0", startsAt: today + hour * 16.25,
                      endsAt: today + hour * 17.75, location: "Main Building\nHugo Kulka Room".localized),
        EventResponse(id: "E3", courseId: "C2", startsAt: today + day + hour * 8.25, endsAt: today + day + hour * 9.75,
                      location: "Main Building\nBielefeld Room".localized),
        EventResponse(id: "E4", title: "Functional Concepts".localized, courseId: "C7", startsAt: today + day + hour * 11,
                      endsAt: today + day + hour * 12.5, location: "Main Building\nBasement".localized),
        EventResponse(id: "E5", startsAt: today + day + hour * 12, endsAt: today + day + hour * 13.5,
                      location: "Building 42\nRoom 135".localized, summary: "Building Your Own Operating System".localized),
        EventResponse(id: "E6", courseId: "C4", startsAt: today + day + hour * 13.25, endsAt: today + day + hour * 14.75,
                      location: "Main Building\nBielefeld Room".localized),
        EventResponse(id: "E7", courseId: "C0", startsAt: today + day * 2 + hour * 10, endsAt: today + day * 2 + hour * 10.5,
                      location: "Main Building\nHugo Kulka Room".localized),
        EventResponse(id: "E8", courseId: "C4", startsAt: today + day * 2 + hour * 14, endsAt: today + day * 2 + hour * 15.5,
                      location: "Main Building\nBielefeld Room".localized),
        EventResponse(id: "E9", courseId: "C2", startsAt: today + day * 4 + hour * 9, endsAt: today + day * 4 + hour * 10.5,
                      location: "Main Building\nHugo Kulka Room".localized),
        EventResponse(id: "E10", courseId: "C5", startsAt: today + day * 5 + hour * 10, endsAt: today + day * 5 + hour * 16,
                      location: "Building 42\nMultimedia Room".localized),
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

        try announcements.forEach { response in
            try response.coreDataObject(organization: organization, in: context)
        }

        let codingCourse = try Course.fetch(byId: "C7", in: context)!
        let numericalAnalysisCourse = try Course.fetch(byId: "C0", in: context)!
        let dataScienceCourse = try Course.fetch(byId: "C5", in: context)!

        try codingCourseFolders.forEach { response in
            try response.coreDataObject(course: codingCourse, in: context)
        }

        try codingCourseDocuments.forEach { response in
            let document = try response.coreDataObject(course: codingCourse, in: context)
            guard document.id != "F3" else { return }
            document.state.downloadedAt = now
            document.downloadedBy.formUnion([user])
        }

        try numericalAnalysisCourseDocuments.forEach { response in
            let document = try response.coreDataObject(course: numericalAnalysisCourse, in: context)
            document.state.downloadedAt = now
            document.downloadedBy.formUnion([user])
        }

        try dataScienceCourseDocuments.forEach { response in
            let document = try response.coreDataObject(course: dataScienceCourse, in: context)
            document.state.downloadedAt = now
            document.downloadedBy.formUnion([user])
        }

        try events.forEach { response in
            let event = try response.coreDataObject(user: user, in: context)
            event.id += "-A"
        }

        try events.forEach { response in
            let event = try response.coreDataObject(user: user, in: context)
            event.id += "-B"
            event.startsAt += week
            event.endsAt += week
        }
    }
}
