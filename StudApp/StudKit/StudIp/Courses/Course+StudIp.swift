//
//  Course+StudIp.swift
//  StudKit
//
//  Created by Steffen Ryll on 22.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import CoreSpotlight

extension Course {
    public static func update(in context: NSManagedObjectContext, handler: @escaping ResultHandler<[Course]>) {
        let studIpService = ServiceContainer.default[StudIpService.self]
        guard let userId = studIpService.userId else { return }

        studIpService.api.requestCollection(.courses(forUserId: userId)) { (result: Result<[CourseResponse]>) in
            guard let models = result.value else { return handler(result.replacingValue(nil)) }

            do {
                let updatedCourses = try Course.update(using: models, in: context)

                try? Semester.fetchNonHidden(in: context).forEach { semester in
                    semester.state.areCoursesFetchedFromRemote = true

                    if #available(iOSApplicationExtension 11.0, *) {
                        NSFileProviderManager.default.signalEnumerator(for: semester.itemIdentifier) { _ in }
                    }
                }

                if #available(iOSApplicationExtension 11.0, *) {
                    NSFileProviderManager.default.signalEnumerator(for: .rootContainer) { _ in }
                    NSFileProviderManager.default.signalEnumerator(for: .workingSet) { _ in }
                }

                handler(result.replacingValue(updatedCourses))
            } catch {
                handler(.failure(error))
            }
        }
    }

    public func updateFiles(in context: NSManagedObjectContext, handler: @escaping ResultHandler<[File]>) {
        let studIpService = ServiceContainer.default[StudIpService.self]
        studIpService.api.requestCollection(.filesInCourse(withId: id)) { (result: Result<[FileResponse]>) in
            guard let models = result.value else { return handler(result.replacingValue(nil)) }

            do {
                let updatedFiles = try File.update(using: models, in: context)

                self.state.areFilesFetchedFromRemote = true

                if #available(iOSApplicationExtension 11.0, *) {
                    NSFileProviderManager.default.signalEnumerator(for: self.itemIdentifier) { _ in }
                    NSFileProviderManager.default.signalEnumerator(for: .workingSet) { _ in }
                }

                handler(result.replacingValue(updatedFiles))
            } catch {
                handler(.failure(error))
            }
        }
    }

    public func updateAnnouncements(in context: NSManagedObjectContext, handler: @escaping ResultHandler<[Announcement]>) {
        let studIpService = ServiceContainer.default[StudIpService.self]
        studIpService.api.requestCollection(.announcementsInCourse(withId: id)) { (result: Result<[AnnouncementResponse]>) in
            guard let models = result.value else { return handler(result.replacingValue(nil)) }

            do {
                let updatedAnnouncements = try Announcement.update(using: models, in: context)
                handler(result.replacingValue(updatedAnnouncements))
            } catch {
                handler(.failure(error))
            }
        }
    }

    public var url: URL? {
        let studIpService = ServiceContainer.default[StudIpService.self]
        guard
            let baseUrl = studIpService.api.baseUrl?.deletingLastPathComponent(),
            let url = URL(string: "\(baseUrl)/dispatch.php/course/overview?cid=\(id)")
        else { return nil }
        return url
    }
}
