//
//  ColorPickerViewModel.swift
//  StudKit
//
//  Created by Steffen Ryll on 11.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public final class ColorPickerViewModel<Color>: DataSourceSection {
    public typealias Row = (key: Int, value: Color)

    private let colors: [Row]
    private var completion: (Int, Color) -> Void

    public init(colors: [Int: Color], completion: @escaping (Int, Color) -> Void) {
        self.colors = colors.enumerated()
            .sorted { $0.element.key < $1.element.key }
            .map { $1 }
        self.completion = completion
    }

    public var numberOfRows: Int {
        return colors.count
    }

    public subscript(rowAt index: Int) -> Row {
        return colors[index]
    }

    public func didSelectColor(atIndex index: Int) {
        completion(colors[index].key, colors[index].value)
    }
}
