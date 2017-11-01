//
//  StudKitServiceProvider.swift
//  StudKit
//
//  Created by Steffen Ryll on 31.10.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public class StudKitServiceProvider : ServiceProvider {
    public init() { }
    
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
        let credentials = ApiCredentials(username: "username", password: "password")
        return StudIpService(credentials: credentials)
    }
    
    func provideSemesterService() -> SemesterService {
        return SemesterService()
    }
    
    func provideCourseService() -> CourseService {
        return CourseService()
    }
    
    public func registerServices(in container: ServiceContainer) {
        container[JSONDecoder.self] = provideJsonDecoder()
        container[StorageService.self] = provideStorageService()
        container[CoreDataService.self] = provideCoreDataService()
        container[StudIpService.self] = provideStudIpService()
        container[SemesterService.self] = provideSemesterService()
        container[CourseService.self] = provideCourseService()
    }
}
