//
//  ByTypeNameIdentifiable.swift
//  StudKit
//
//  Created by Steffen Ryll on 20.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

/// Something that can be identified by its non-generic type name, e.g. a database table or table view cell.
public protocol ByTypeNameIdentifiable {}

public extension ByTypeNameIdentifiable {
    /// This object's type name without generic type information, e.g. `Set` instead of `Set<Int>`.
    public static var typeIdentifier: String {
        let typeName = String(describing: Self.self)
        return typeName
            .components(separatedBy: "<")
            .first ?? typeName
    }
}

// MARK: - Conformances

extension UITableViewCell: ByTypeNameIdentifiable {}
