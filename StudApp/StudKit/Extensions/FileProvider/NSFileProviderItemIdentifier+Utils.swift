//
//  NSFileProviderItemIdentifier+Utils.swift
//  StudFileProvider
//
//  Created by Steffen Ryll on 11.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import FileProvider

public extension NSFileProviderItemIdentifier {
    /// Models that can be represented by a file provider item identifier.
    ///
    /// - workingSet: Working set containing items currently considered important.
    /// - root: Root container.
    /// - semester: Semester by its id.
    /// - course: Course by its id.
    /// - file: Folder or document by its id.
    public enum Models {
        case workingSet
        case root
        case semester(id: String)
        case course(id: String)
        case file(id: String)
    }

    private var parts: [String] {
        return rawValue.components(separatedBy: "-")
    }

    /// Item's id contained in this identifier, e.g. the course id.
    public var id: String {
        guard let id = parts.last else {
            fatalError("Cannot parse item identifier '\(rawValue)'.")
        }
        return id
    }

    /// Type of model that this item identifier describes.
    public var model: Models {
        if #available(iOSApplicationExtension 11.0, *) {
            if self == .workingSet {
                return .workingSet
            } else if self == .rootContainer {
                return .root
            }
        }

        switch parts.first {
        case "semester"?: return .semester(id: id)
        case "course"?: return .course(id: id)
        case "file"?: return .file(id: id)
        default: fatalError("Cannot parse item identifier '\(rawValue)'.")
        }
    }
}
