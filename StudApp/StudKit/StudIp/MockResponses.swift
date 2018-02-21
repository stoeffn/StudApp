//
//  MockResponses.swift
//  StudKit
//
//  Created by Steffen Ryll on 21.02.18.
//  Copyright © 2018 Steffen Ryll. All rights reserved.
//

import CoreData

struct MockResponses {
    lazy var semesters = [
        SemesterResponse(id: "S0", title: "Winter 2016/17".localized, beginsAt: Date(timeIntervalSince1970: 1475338860),
                         endsAt: Date(timeIntervalSince1970: 1488388860)),
        SemesterResponse(id: "S1", title: "Summer 2017".localized, beginsAt: Date(timeIntervalSince1970: 1491004800),
                         endsAt: Date(timeIntervalSince1970: 1504224000)),
        SemesterResponse(id: "S2", title: "Winter 2017/18".localized, beginsAt: Date(timeIntervalSince1970: 1504282860),
                         endsAt: Date(timeIntervalSince1970: 1519924860)),
    ]

    lazy var currentUser = UserResponse(id: "U0", username: "student", givenName: "Successful", familyName: "Student")

    lazy var theCount = UserResponse(id: "U1", username: "theCount".localized, givenName: "Count".localized,
                                     familyName: "von Count".localized)

    lazy var courses = [
        CourseResponse(id: "C0", number: "3.00000000001", title: "Numerical Analysis".localized,
                       subtitle: "Optimizing Algorithms for Computers".localized, location: "Bielefeld Room".localized,
                       summary: nil, lecturers: [theCount], beginSemesterId: "S2", endSemesterId: "S2"),
        CourseResponse(id: "C1", number: "42", title: "Computer Architecture".localized, subtitle: nil,
                       location: "Multimedia Room".localized,
                       summary: "In this lecture, you will learn how to…", lecturers: [], beginSemesterId: "S2", endSemesterId: "S2"),
    ]

    mutating func insert(into context: NSManagedObjectContext) throws {
        try currentUser.coreDataObject(in: context)
        try semesters.forEach { try $0.coreDataObject(in: context) }
        try courses.forEach { try $0.coreDataObject(in: context) }
    }
}
