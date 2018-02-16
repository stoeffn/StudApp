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
        studIpService.api.requestCollection(.semesters, ignoreLastAccess: !enforce) { (result: Result<[SemesterResponse]>) in
            let result = result.map { try update(fetchRequest(), with: $0, in: context) }
            handler(result)
        }
    }

    static func update(_ existingObjects: NSFetchRequest<Semester>, with response: [SemesterResponse],
                       in context: NSManagedObjectContext) throws -> [Semester] {
        let semesters = try Semester.update(existingObjects, with: response, in: context) { try $0.coreDataObject(in: context) }

        if #available(iOSApplicationExtension 11.0, *) {
            NSFileProviderManager.default.signalEnumerator(for: .rootContainer) { _ in }
            NSFileProviderManager.default.signalEnumerator(for: .workingSet) { _ in }
        }

        return semesters
    }
}
