//
//  SemesterService.swift
//  StudKit
//
//  Created by Steffen Ryll on 08.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

public final class SemesterService {
    private let studIp: StudIpService

    init() {
        studIp = ServiceContainer.default[StudIpService.self]
    }

    public func updateSemesters(in context: NSManagedObjectContext, handler: @escaping ResultHandler<[Semester]>) {
        studIp.api.requestCompleteCollection(.semesters) { (result: Result<[SemesterModel]>) in
            Semester.update(using: result, in: context, handler: handler)
        }
    }
}