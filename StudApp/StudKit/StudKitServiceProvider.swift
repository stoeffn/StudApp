//
//  StudKitServiceProvider.swift
//  StudKit
//
//  Created by Steffen Ryll on 31.10.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public class StudKitServiceProvider: ServiceProvider {
    public init() {}

    static let studIpBaseUrl = URL(string: "https://studip.uni-hannover.de/api.php")!
    static let studIpRealm = "luh"
    static let appGroupIdentifier = "group.SteffenRyll.StudKit"

    func provideJsonDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }

    func provideStorageService() -> StorageService {
        return StorageService()
    }

    func provideCoreDataService() -> CoreDataService {
        return CoreDataService(modelName: "StudKit", appGroupIdentifier: StudKitServiceProvider.appGroupIdentifier)
    }

    func provideStudIpService() -> StudIpService {
        return StudIpService(baseUrl: StudKitServiceProvider.studIpBaseUrl, realm: StudKitServiceProvider.studIpRealm)
    }

    public func registerServices(in container: ServiceContainer) {
        container[JSONDecoder.self] = provideJsonDecoder()
        container[StorageService.self] = provideStorageService()
        container[CoreDataService.self] = provideCoreDataService()
        container[StudIpService.self] = provideStudIpService()
        container[SemesterService.self] = SemesterService()
        container[CourseService.self] = CourseService()
        container[FileService.self] = FileService()
    }
}
