//
//  ColorPickerViewModel.swift
//  StudKit
//
//  Created by Steffen Ryll on 11.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public final class ColorPickerViewModel: DataSourceSection {
    public typealias Row = (key: Int, value: UIColor)

    private let colors: [Row]

    public var handler: (Int, UIColor) -> Void

    public init(handler: @escaping (Int, UIColor) -> Void) {
        let colors = UI.Colors.pickerColors.enumerated().sorted { $0.element.key < $1.element.key }.map { $1 }

        self.handler = handler
        self.colors = Array(colors)
    }

    public var numberOfRows: Int {
        return colors.count
    }

    public subscript(rowAt index: Int) -> Row {
        return colors[index]
    }

    public func didSelectColor(atIndex index: Int) {
        handler(colors[index].key, colors[index].value)
    }
}
