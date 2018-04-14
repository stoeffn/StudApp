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

    // MARK: - Organizations

    lazy var organization = OrganizationRecord(id: "O0")

    // MARK: - Semesters

    lazy var semesters = [
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

    lazy var currentUser = UserResponse(id: "U0", username: "murphy", givenName: "Murphy", familyName: "Cooper")

    lazy var theCount = UserResponse(id: "U1", username: "theCount".localized, givenName: "Count".localized,
                                     familyName: "von Count".localized)

    lazy var professorProton = UserResponse(id: "U2", username: "proton", givenName: "Professor", familyName: "Proton")

    lazy var langdon = UserResponse(id: "U3", username: "langdon", givenName: "Robert", familyName: "Langdon")

    lazy var tesla = UserResponse(id: "U4", username: "tesla", givenName: "Nikola", familyName: "Tesla")

    lazy var cooper = UserResponse(id: "U5", username: "coop", givenName: "Joseph", familyName: "Cooper")

    // MARK: - Courses

    lazy var courses = [
        CourseResponse(id: "C0", number: "1.00000000001", title: "Numerical Analysis".localized,
                       subtitle: "Optimizing Algorithms for Computers".localized, location: "Bielefeld Room".localized,
                       groupId: 1, lecturers: [theCount], beginSemesterId: "S3", endSemesterId: "S3"),
        CourseResponse(id: "C1", number: "3.14", title: "Linear Algebra I".localized,
                       subtitle: "Vectors and Stuff".localized, location: "Hugo Kulka Room".localized,
                       groupId: 1, lecturers: [cooper, theCount], beginSemesterId: "S3", endSemesterId: "S3"),
        CourseResponse(id: "C2", number: "42", title: "Computer Architecture".localized,
                       location: "Multimedia Room".localized, summary: "In this lecture, you will learn how to…",
                       groupId: 3, lecturers: [professorProton], beginSemesterId: "S3", endSemesterId: "S3"),
        CourseResponse(id: "C3", number: nil, title: "Theoretical Stud.IP Science".localized,
                       groupId: 4, lecturers: [professorProton], beginSemesterId: "S3", endSemesterId: "S3"),
        CourseResponse(id: "C3", number: nil, title: "Data Science 101".localized,
                       groupId: 4, lecturers: [tesla], beginSemesterId: "S3", endSemesterId: "S3"),
        CourseResponse(id: "C4", number: nil, title: "StudApp Feedback".localized,
                       groupId: 5, lecturers: [tesla], beginSemesterId: "S0", endSemesterId: "S3"),
    ]

    // MARK: - Inserting Data

    mutating func insert(into context: NSManagedObjectContext) throws {
        let now = Date()

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
    }
}
