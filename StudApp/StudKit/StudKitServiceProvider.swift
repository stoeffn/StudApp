//
//  StudKitServiceProvider.swift
//  StudKit
//
//  Created by Steffen Ryll on 31.10.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public class StudKitServiceProvider: ServiceProvider {
    static let studIpBaseUrl = URL(string: "https://studip.uni-hannover.de/api.php")!
    static let studIpRealm = "luh"
    static let appGroupIdentifier = "group.SteffenRyll.StudKit"

    private let currentTarget: Targets

    public init(target: Targets) {
        currentTarget = target
    }

    func provideJsonDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }

    func provideCoreDataService() -> CoreDataService {
        return CoreDataService(modelName: "StudKit", appGroupIdentifier: StudKitServiceProvider.appGroupIdentifier)
    }

    func provideStudIpService() -> StudIpService {
        return StudIpService(baseUrl: StudKitServiceProvider.studIpBaseUrl, realm: StudKitServiceProvider.studIpRealm)
    }

    public func registerServices(in container: ServiceContainer) {
        container[JSONDecoder.self] = provideJsonDecoder()
        container[StorageService.self] = StorageService()
        container[CoreDataService.self] = provideCoreDataService()
        container[HistoryService.self] = HistoryService(currentTarget: currentTarget)
        container[StudIpService.self] = provideStudIpService()
        container[SemesterService.self] = SemesterService()
        container[CourseService.self] = CourseService()
        container[FileService.self] = FileService()
    }
}
