//
//  StudApp—Stud.IP to Go
//  Copyright © 2018, Steffen Ryll
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see http://www.gnu.org/licenses/.
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
    public init(providers: [ServiceProvider] = []) {
        register(providers: providers)
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
