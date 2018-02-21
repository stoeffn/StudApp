//
//  StudKitServiceProvider.swift
//  StudKit
//
//  Created by Steffen Ryll on 31.10.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public class StudKitServiceProvider: ServiceProvider {
    private let currentTarget: Targets
    private let isRunningUiTests: Bool
    private let extensionContext: NSExtensionContext?
    private let openUrl: ((URL, ((Bool) -> Void)?) -> Void)?

    public init(currentTarget: Targets, isRunningUiTests: Bool = false, extensionContext: NSExtensionContext? = nil,
                openUrl: ((URL, ((Bool) -> Void)?) -> Void)? = nil) {
        self.currentTarget = currentTarget
        self.isRunningUiTests = isRunningUiTests
        self.extensionContext = extensionContext
        self.openUrl = openUrl
    }

    func provideContextService() -> ContextService {
        return ContextService(currentTarget: currentTarget, isRunningUiTests: isRunningUiTests,
                              extensionContext: extensionContext, openUrl: openUrl)
    }

    func provideReachabilityService() -> ReachabilityService {
        let service = ReachabilityService()
        service.isActive = true
        return service
    }

    func provideJsonEncoder() -> JSONEncoder {
        let decoder = JSONEncoder()
        decoder.dateEncodingStrategy = .secondsSince1970
        return decoder
    }

    func provideJsonDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }

    func provideCoreDataService() -> CoreDataService {
        return CoreDataService(modelName: "StudKit", appGroupIdentifier: App.groupIdentifier)
    }

    func provideStoreService() -> StoreService {
        guard let verificationApiBaseUrl = URL(string: "https://studapp.stoeffn.de/api/v1") else { fatalError() }
        let verificationApi = Api<StoreRoutes>(baseUrl: verificationApiBaseUrl)
        return StoreService(verificationApi: verificationApi)
    }

    func provideStudIpService() -> StudIpService {
        return isRunningUiTests ? MockStudIpService() : StudIpService()
    }

    public func registerServices(in container: ServiceContainer) {
        container[JSONEncoder.self] = provideJsonEncoder()
        container[JSONDecoder.self] = provideJsonDecoder()
        container[ContextService.self] = provideContextService()
        container[ReachabilityService.self] = provideReachabilityService()
        container[CacheService.self] = CacheService()
        container[StoreService.self] = provideStoreService()
        container[StorageService.self] = StorageService()
        container[CoreDataService.self] = provideCoreDataService()
        container[PersistentHistoryService.self] = PersistentHistoryService(currentTarget: currentTarget)
        container[StudIpService.self] = provideStudIpService()
    }
}
