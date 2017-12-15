//
//  ColorPickerViewModel.swift
//  StudKit
//
//  Created by Steffen Ryll on 11.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public final class ColorPickerViewModel {
    private let colors = Array(UI.Colors.pickerColors.enumerated().sorted { $0.element.key < $1.element.key } .map { $1 })

    public var handler: (Int, UIColor) -> Void

    public init(handler: @escaping (Int, UIColor) -> Void) {
        self.handler = handler
    }

    public func didSelectColor(atIndex index: Int) {
        handler(colors[index].key, colors[index].value)
    }
}

extension ColorPickerViewModel: DataSourceSection {
    public typealias Row = (Int, UIColor)

    public var numberOfRows: Int {
        return colors.count
    }

    public subscript(rowAt index: Int) -> (Int, UIColor) {
        return colors[index]
    }
}
