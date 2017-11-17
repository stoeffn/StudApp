//
//  TestHelper.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 17.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

@testable import StudKit

#if os(OSX)
    import Cocoa
#else
    import UIKit
    typealias NSColor = UIColor
#endif

extension UserDefaults {
    subscript(key: DefaultsKey<NSColor?>) -> NSColor? {
        get { return unarchive(key) }
        set { archive(key, newValue) }
    }

    subscript(key: DefaultsKey<NSColor>) -> NSColor {
        get { return unarchive(key) ?? .white }
        set { archive(key, newValue) }
    }

    subscript(key: DefaultsKey<[NSColor]>) -> [NSColor] {
        get { return unarchive(key) ?? [] }
        set { archive(key, newValue) }
    }
}

enum TestEnum: String {
    case A, B, C
}

extension UserDefaults {
    subscript(key: DefaultsKey<TestEnum?>) -> TestEnum? {
        get { return unarchive(key) }
        set { archive(key, newValue) }
    }
}

extension UserDefaults {
    subscript(key: DefaultsKey<TestEnum>) -> TestEnum {
        get { return unarchive(key) ?? .A }
        set { archive(key, newValue) }
    }
}

enum TestEnum2: Int {
    case ten = 10
    case twenty = 20
    case thirty = 30
}

extension UserDefaults {
    subscript(key: DefaultsKey<TestEnum2?>) -> TestEnum2? {
        get { return unarchive(key) }
        set { archive(key, newValue) }
    }
}
