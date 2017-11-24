//
//  Course+StudIp.swift
//  StudKit
//
//  Created by Steffen Ryll on 22.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

extension Course {
    public static func update(in context: NSManagedObjectContext, handler: @escaping ResultHandler<[Course]>) {
        let studIpService = ServiceContainer.default[StudIpService.self]
        guard let userId = studIpService.currentUserId else { return }

        studIpService.api.requestCompleteCollection(.courses(forUserId: userId)) { (result: Result<[CourseResponse]>) in
            Course.update(using: result, in: context, handler: handler)

            guard let semesters = try? Semester.fetchNonHidden(in: context) else { return }
            for semester in semesters {
                NSFileProviderManager.default.signalEnumerator(for: semester.itemIdentifier) { _ in }
            }
            NSFileProviderManager.default.signalEnumerator(for: .workingSet) { _ in }
        }
    }

    public func updateFiles(in context: NSManagedObjectContext, handler: @escaping ResultHandler<[File]>) {
        let studIpService = ServiceContainer.default[StudIpService.self]
        studIpService.api.requestCompleteCollection(.filesInCourse(withId: id)) { (result: Result<[FileResponse]>) in
            File.update(using: result, in: context, handler: handler)

            NSFileProviderManager.default.signalEnumerator(for: self.itemIdentifier) { _ in }
            NSFileProviderManager.default.signalEnumerator(for: .workingSet) { _ in }
        }
    }
}
