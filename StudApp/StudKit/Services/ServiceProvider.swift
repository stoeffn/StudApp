//
//  ServiceProvider.swift
//  StudKit
//
//  Created by Steffen Ryll on 23.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

/// Protocol for service providers that can register their services in a service container.
public protocol ServiceProvider: class {
    /// Registers the provider's services in a container.
    ///
    /// - Parameter container: Service container in which the services will be registered.
    func registerServices(in container: ServiceContainer)
}
