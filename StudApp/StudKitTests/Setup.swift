//
//  Setup.swift
//  StudKitTests
//
//  Created by Steffen Ryll on 24.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

@testable import StudKit

@objc(Setup)
final class Setup: NSObject {
    override init() {
        ServiceContainer.default.register(providers: StudKitTestsServiceProvider())
    }
}
