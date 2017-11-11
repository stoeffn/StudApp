//
//  JSONDecoder+Resource.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 25.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import Foundation

extension JSONDecoder {
    /// Decodes a top-level value of the given type from the given resourse file's contents that must be a JSON
    /// representation.
    ///
    /// - parameter type: The type of the value to decode.
    /// - parameter data: The data to decode from.
    /// - returns: A value of the requested type.
    /// - throws: `DecodingError.dataCorrupted` if values requested from the payload are corrupted, or if the given data is not valid JSON.
    /// - throws: An error if any value throws an error during decoding.
    public func decode<T>(_ type: T.Type, fromResource filename: String) throws -> T where T: Decodable {
        return try decode(type, from: Data(fromResource: filename))
    }
}
