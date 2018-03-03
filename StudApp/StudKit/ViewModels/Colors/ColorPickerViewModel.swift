//
//  ColorPickerViewModel.swift
//  StudKit
//
//  Created by Steffen Ryll on 11.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public final class ColorPickerViewModel<Color>: DataSourceSection {
    public typealias ColorAndTitle = (color: Color, title: String)
    public typealias Row = (key: Int, value: ColorAndTitle)

    private let colors: [Row]
    private var completion: (Row) -> Void

    public init(colors: [Row], completion: @escaping (Row) -> Void) {
        self.colors = colors
        self.completion = completion
    }

    public convenience init(colors: [Int: ColorAndTitle], completion: @escaping (Row) -> Void) {
        let colors = colors.enumerated()
            .sorted { $0.element.key < $1.element.key }
            .map { $1 }
        self.init(colors: colors, completion: completion)
    }

    public var numberOfRows: Int {
        return colors.count
    }

    public subscript(rowAt index: Int) -> Row {
        return colors[index]
    }

    public func didSelectColor(atIndex index: Int) {
        completion(colors[index])
    }
}
