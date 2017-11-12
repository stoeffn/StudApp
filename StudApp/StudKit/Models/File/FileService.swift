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

    public func update(filesInCourseWithId courseId: String, in context: NSManagedObjectContext,
                       handler: @escaping ResultHandler<[File]>) {
        studIp.api.requestCompleteCollection(.filesInCourse(withId: courseId)) { (result: Result<[FileModel]>) in
            File.update(using: result, in: context, handler: handler)
        }
    }

    public func update(fileWithId id: String, in context: NSManagedObjectContext, handler: @escaping ResultHandler<File>) {
        studIp.api.requestDecoded(.file(withId: id)) { (result: Result<FileModel>) in
            File.update(using: result, in: context, handler: handler)
        }
    }
}
