//
//  Semester+StudIp.swift
//  StudKit
//
//  Created by Steffen Ryll on 08.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

extension Semester {
    public static func update(in context: NSManagedObjectContext, enforce: Bool = false,
                              handler: @escaping ResultHandler<[Semester]>) {
        let studIpService = ServiceContainer.default[StudIpService.self]
        studIpService.api.requestCompleteCollection(.semesters,
                                                    ignoreLastAccess: !enforce) { (result: Result<[SemesterResponse]>) in
            Semester.update(using: result, in: context, handler: handler)

            if #available(iOSApplicationExtension 11.0, *) {
                NSFileProviderManager.default.signalEnumerator(for: .rootContainer) { _ in }
                NSFileProviderManager.default.signalEnumerator(for: .workingSet) { _ in }
                                                        }
        }
    }
}
