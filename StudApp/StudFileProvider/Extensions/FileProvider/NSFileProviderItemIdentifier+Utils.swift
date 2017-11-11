//
//  NSFileProviderItemIdentifier+Utils.swift
//  StudFileProvider
//
//  Created by Steffen Ryll on 11.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import FileProvider

public extension NSFileProviderItemIdentifier {
    public enum ModelType {
        case root
        case workingSet
        case semester(id: String)
        case course(id: String)
        case file(id: String)
    }

    private var parts: [String] {
        return rawValue.components(separatedBy: "-")
    }

    public var id: String {
        guard let id = parts.last else {
            fatalError("Cannot parse item identifier '\(rawValue)'.")
        }
        return id
    }

    public var modelType: ModelType {
        if self == .rootContainer {
            return .root
        } else if self == .workingSet {
            return .workingSet
        }

        switch parts.first {
        case "semester"?: return .semester(id: id)
        case "course"?: return .course(id: id)
        case "file"?: return .file(id: id)
        default: fatalError("Cannot parse item identifier '\(rawValue)'.")
        }
    }
}
