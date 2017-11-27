//
//  StudKitServiceProvider.swift
//  StudKit
//
//  Created by Steffen Ryll on 31.10.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public class StudKitServiceProvider: ServiceProvider {
    static let kitBundle = Bundle(for: StudKitServiceProvider.self)
    static let appGroupIdentifier = "group.SteffenRyll.StudKit"
    static let iCloudContainerIdentifier = "iCloud.SteffenRyll.StudKit"

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
        return StudIpService()
    }

    public func registerServices(in container: ServiceContainer) {
        container[JSONDecoder.self] = provideJsonDecoder()
        container[StorageService.self] = StorageService()
        container[CoreDataService.self] = provideCoreDataService()
        container[HistoryService.self] = HistoryService(currentTarget: currentTarget)
        container[StudIpService.self] = provideStudIpService()
    }
}
