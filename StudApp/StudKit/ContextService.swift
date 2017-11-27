//
//  ContextService.swift
//  StudKit
//
//  Created by Steffen Ryll on 27.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public final class ContextService {
    public let currentTarget: Targets
    public let extensionContext: NSExtensionContext?

    init(currentTarget: Targets, extensionContext: NSExtensionContext?) {
        self.currentTarget = currentTarget
        self.extensionContext = extensionContext
    }
}
