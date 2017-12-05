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

    public var handler: (Color) -> Void

    public init(handler: @escaping (Color) -> Void) {
        self.handler = handler

        let orderIdSortDescriptor = NSSortDescriptor(keyPath: \Color.orderId, ascending: true)
        colors = (try? Color.fetch(in: coreData.viewContext, sortDescriptors: [orderIdSortDescriptor])) ?? []
    }

    public func didSelectColor(atIndex index: Int) {
        handler(colors[index])
    }
}
