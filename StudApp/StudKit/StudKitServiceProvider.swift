//
//  StudKitServiceProvider.swift
//  StudKit
//
//  Created by Steffen Ryll on 31.10.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public class StudKitServiceProvider : ServiceProvider {
    public init() { }
    
    func provideStorageService() -> StorageService {
        return StorageService()
    }
    
    public func registerServices(in container: ServiceContainer) {
        container[StorageService.self] = provideStorageService()
    }
}
