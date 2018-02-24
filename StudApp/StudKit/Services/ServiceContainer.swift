//
//  ServiceContainer.swift
//  StudKit
//
//  Created by Steffen Ryll on 23.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

/// Basic container for services that aims to ease the implementation of the
/// [Dependency Injection](https://en.wikipedia.org/wiki/Dependency_injection) design pattern.
///
/// It provides the ability to store and resolve dependencies making it easier to modularize, test, and maintain
/// applications components.
public final class ServiceContainer {
    /// Default service container, which is accessible from anywhere.
    public static let `default` = ServiceContainer()

    private var services = [String: Any]()

    /// Creates a service container and registers the services created by the providers given.
    ///
    /// - Parameter providers: Service providers that know how to create their services.
    public init(providers: ServiceProvider...) {
        for provider in providers {
            provider.registerServices(in: self)
        }
    }

    /// Returns a string representation for the given type that should be used as the key for identifying this type.
    private func key<Value>(for type: Value.Type) -> String {
        return String(describing: type)
    }

    /// Accesses a service of the type given.
    ///
    /// - Note: There is nothing stopping you from overriding a service that has already been registered.
    /// - Warning: Trying to access a service for a type that has not been registered will result in a fatal error!
    public subscript<Value>(_ type: Value.Type) -> Value {
        get {
            guard let service = services[key(for: type)] as? Value else {
                fatalError("No service registered for '\(type)'.")
            }
            return service
        }
        set {
            services[key(for: type)] = newValue
        }
    }

    /// Registers the services created by the providers given.
    ///
    /// - Parameter providers: Service providers that know how to create their services.
    public func register(providers: [ServiceProvider]) {
        for provider in providers {
            provider.registerServices(in: self)
        }
    }
}
