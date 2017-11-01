//
//  CourseService.swift
//  StudKit
//
//  Created by Steffen Ryll on 22.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

public final class CourseService {
    private let studIp: StudIpService
    private let userId = "f1480088c469549fb9bb29cfef4fa1ad"

    init() {
        studIp = ServiceContainer.default[StudIpService.self]
    }

    public func updateCourses(in context: NSManagedObjectContext, completionHandler: @escaping ResultCallback<[Course]>) {
        studIp.api.requestCompleteCollection(.courses(forUserId: userId)) { (result: Result<[CourseModel]>) in
            Course.update(using: result, in: context, completionHandler: completionHandler)
        }
    }
}
