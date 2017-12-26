//
//  ObjectIdentifier.swift
//  StudKit
//
//  Created by Steffen Ryll on 26.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public struct ObjectIdentifier: ByTypeNameIdentifiable {
    let typeIdentifier: String

    let id: String?

    init(typeIdentifier: String, id: String? = nil) {
        self.typeIdentifier = typeIdentifier.lowercased()
        self.id = id
    }
}

// MARK: - Utilities

public extension ObjectIdentifier {
    public func isOf(type: CDIdentifiable.Type) -> Bool {
        return typeIdentifier == type.typeIdentifier
    }
}

// MARK: - Coding

extension ObjectIdentifier: RawRepresentable {
    public typealias RawValue = String

    private static let rawValueSeparator = "-"

    private static let rootTypeIdentifier: String = {
        guard #available(iOS 11, *) else { return "root" }
        return NSFileProviderItemIdentifier.rootContainer.rawValue.lowercased()
    }()

    private static let workingSetTypeIdentifier: String = {
        guard #available(iOS 11, *) else { return "workingset" }
        return NSFileProviderItemIdentifier.workingSet.rawValue.lowercased()
    }()

    public init?(rawValue: String) {
        let parts = rawValue.components(separatedBy: ObjectIdentifier.rawValueSeparator)

        switch parts.first {
        case ObjectIdentifier.rootTypeIdentifier?:
            self.init(typeIdentifier: ObjectIdentifier.rootTypeIdentifier)
        case ObjectIdentifier.workingSetTypeIdentifier?:
            self.init(typeIdentifier: ObjectIdentifier.workingSetTypeIdentifier)
        default:
            guard
                let typeIdentifier = parts.first,
                let id = parts.last,
                parts.count == 2
            else { return nil }
            self.init(typeIdentifier: typeIdentifier, id: id)
        }
    }

    public var rawValue: String {
        switch typeIdentifier {
        case ObjectIdentifier.rootTypeIdentifier:
            return ObjectIdentifier.rootTypeIdentifier
        case ObjectIdentifier.workingSetTypeIdentifier:
            return ObjectIdentifier.workingSetTypeIdentifier
        default:
            guard let id = id else { fatalError("Cannot create object identifier representation for object without id.") }
            return typeIdentifier + ObjectIdentifier.rawValueSeparator + id
        }
    }
}
