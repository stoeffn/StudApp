//
//  ColorPickerViewModel.swift
//  StudKit
//
//  Created by Steffen Ryll on 11.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public final class ColorPickerViewModel {
    private let coreData = ServiceContainer.default[CoreDataService.self]

    public let colors: [Color]

    public var colorable: CDColorable

    public var completionHandler: ((CDColorable) -> Void)?

    public init(colorable: CDColorable) {
        self.colorable = colorable

        let orderIdSortDescriptor = NSSortDescriptor(keyPath: \Color.orderId, ascending: true)
        colors = (try? Color.fetch(in: coreData.viewContext, sortDescriptors: [orderIdSortDescriptor])) ?? []
    }

    public func didSelectColor(atIndex index: Int) {
        colorable.color = colors[index]
        completionHandler?(colorable)
    }
}
