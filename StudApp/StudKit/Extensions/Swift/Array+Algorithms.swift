//
//  Array+Algorithms.swift
//  StudKit
//
//  Created by Steffen Ryll on 17.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

extension Array where Element == [Hashable] {
    func firstCommonElement<Value: Hashable>(type _: Value.Type) -> Value? {
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
