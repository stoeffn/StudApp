//
//  Array+Algorithms.swift
//  StudKit
//
//  Created by Steffen Ryll on 17.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

extension Array where Element == [Hashable] {
    /// Finds the first element common to all contained arrays.
    ///
    /// This algorithm works by advancing an element index, starting with zero. On each iteration, it stores each sub-array's
    /// element at the current index in a set in order to keep track of previously visited elements on a per-array basis. Then,
    /// it checks—for each current element—whether it was visited by each array before. If this is the case, the element is
    /// returned.
    ///
    /// - Parameter type: Type to search for, ignoring all other types. This parameter is necessary due to restrictions in the
    ///                   Swift generics system.
    /// - Returns: First element or `nil` if none was found.
    /// - Complexity: `O(n * m²)` where `n` is the maximum amount of elements in an array and `m` is the number of arrays.
    func firstCommonElement<Value: Hashable>(type: Value.Type) -> Value? {
        guard let shortestSequenceCount = map({ $0.count }).min() else { return nil }
        var visitedElementsArray = map { _ in Set<Value>() }

        for elementIndex in 0..<shortestSequenceCount {
            let elementsAtIndex = flatMap { $0[elementIndex] as? Value }
            for (arrayIndex, element) in elementsAtIndex.enumerated() {
                visitedElementsArray[arrayIndex].insert(element)
            }

            for element in elementsAtIndex {
                let wasElementVisitedInAllArrays = visitedElementsArray.reduce(true) { $0 && $1.contains(element) }
                if wasElementVisitedInAllArrays {
                    return element
                }
            }
        }

        return nil
    }
}
