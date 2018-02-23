//
//  MockResponses.swift
//  StudKit
//
//  Created by Steffen Ryll on 21.02.18.
//  Copyright © 2018 Steffen Ryll. All rights reserved.
//

import CoreData

struct MockResponses {
    lazy var organization = OrganizationRecord(id: "O0")

    lazy var semesters = [
        SemesterResponse(id: "S0", title: "Winter 2016/17".localized, beginsAt: Date(timeIntervalSince1970: 1_475_338_860),
                         endsAt: Date(timeIntervalSince1970: 1_488_388_860)),
        SemesterResponse(id: "S1", title: "Summer 2017".localized, beginsAt: Date(timeIntervalSince1970: 1_491_004_800),
                         endsAt: Date(timeIntervalSince1970: 1_504_224_000)),
        SemesterResponse(id: "S2", title: "Winter 2017/18".localized, beginsAt: Date(timeIntervalSince1970: 1_504_282_860),
                         endsAt: Date(timeIntervalSince1970: 1_519_924_860)),
    ]

    lazy var currentUser = UserResponse(id: "U0", username: "murphy", givenName: "Murphy", familyName: "Cooper")

    lazy var theCount = UserResponse(id: "U1", username: "theCount".localized, givenName: "Count".localized,
                                     familyName: "von Count".localized)

    lazy var professorProton = UserResponse(id: "U2", username: "proton", givenName: "Professor", familyName: "Proton")

    lazy var langdon = UserResponse(id: "U3", username: "langdon", givenName: "Robert", familyName: "Langdon")

    lazy var tesla = UserResponse(id: "U4", username: "tesla", givenName: "Nikola", familyName: "Tesla")

    lazy var cooper = UserResponse(id: "U5", username: "coop", givenName: "Joseph", familyName: "Cooper")

    lazy var courses = [
        CourseResponse(id: "C0", number: "1.00000000001", title: "Numerical Analysis".localized,
                       subtitle: "Optimizing Algorithms for Computers".localized, location: "Bielefeld Room".localized,
                       groupId: 1, lecturers: [theCount], beginSemesterId: "S2", endSemesterId: "S2"),
        CourseResponse(id: "C1", number: "3.14", title: "Linear Algebra I".localized,
                       subtitle: "Vectors and Stuff".localized, location: "Hugo Kulka Room".localized,
                       groupId: 1, lecturers: [cooper, theCount], beginSemesterId: "S2", endSemesterId: "S2"),
        CourseResponse(id: "C2", number: "42", title: "Computer Architecture".localized,
                       location: "Multimedia Room".localized, summary: "In this lecture, you will learn how to…",
                       groupId: 3, lecturers: [professorProton], beginSemesterId: "S2", endSemesterId: "S2"),
        CourseResponse(id: "C3", number: nil, title: "Theoretical Stud.IP Science".localized,
                       groupId: 4, lecturers: [professorProton], beginSemesterId: "S2", endSemesterId: "S2"),
        CourseResponse(id: "C3", number: nil, title: "Data Science 101".localized,
                       groupId: 4, lecturers: [tesla], beginSemesterId: "S2", endSemesterId: "S2"),
    ]

    mutating func insert(into context: NSManagedObjectContext) throws {
        let organization = try self.organization.coreDataObject(in: context)
        try currentUser.coreDataObject(organization: organization, in: context)
        try semesters.forEach { try $0.coreDataObject(organization: organization, in: context) }
        try courses.forEach { try $0.coreDataObject(organization: organization, in: context) }
    }
}
