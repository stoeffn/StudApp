//
//  StudKitUIServiceProvider.swift
//  StudKitUI
//
//  Created by Steffen Ryll on 24.02.18.
//  Copyright © 2018 Steffen Ryll. All rights reserved.
//

import StudKit

public class StudKitUIServiceProvider: ServiceProvider {
    public init() {}

    public func registerServices(in container: ServiceContainer) {
        container[FileIconService.self] = FileIconService()
    }
}
