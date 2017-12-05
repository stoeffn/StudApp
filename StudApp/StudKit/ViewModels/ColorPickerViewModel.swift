//
//  ColorPickerViewModel.swift
//  StudKit
//
//  Created by Steffen Ryll on 11.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public final class ColorPickerViewModel {
    public var handler: (String) -> Void

    public init(handler: @escaping (String) -> Void) {
        self.handler = handler
    }

    public func didSelectColor(atIndex index: Int) {
    }
}
