//
//  FileService.swift
//  StudKit
//
//  Created by Steffen Ryll on 12.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

public final class FileService {
    private let studIp: StudIpService

    init() {
        studIp = ServiceContainer.default[StudIpService.self]
    }

    public func update(filesInCourse course: Course, in context: NSManagedObjectContext,
                       handler: @escaping ResultHandler<[File]>) {
        studIp.api.requestCompleteCollection(.filesInCourse(withId: course.id)) { (result: Result<[FileModel]>) in
            File.update(using: result, in: context, handler: handler)

            NSFileProviderManager.default.signalEnumerator(for: course.itemIdentifier) { _ in }
            NSFileProviderManager.default.signalEnumerator(for: .workingSet) { _ in }
        }
    }

    public func update(folder: File, in context: NSManagedObjectContext, handler: @escaping ResultHandler<File>) {
        studIp.api.requestDecoded(.file(withId: folder.id)) { (result: Result<FileModel>) in
            File.update(using: result, in: context, handler: handler)

            NSFileProviderManager.default.signalEnumerator(for: folder.itemIdentifier) { _ in }
            NSFileProviderManager.default.signalEnumerator(for: .workingSet) { _ in }
        }
    }
}
