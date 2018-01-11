//
//  ContextService.swift
//  StudKit
//
//  Created by Steffen Ryll on 27.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

/// Provides information about the current application context, e.g. 
public final class ContextService {
    public let currentTarget: Targets
    public let extensionContext: NSExtensionContext?
    public let openUrl: ((URL, ((Bool) -> Void)?) -> Void)?

    init(currentTarget: Targets, extensionContext: NSExtensionContext?, openUrl: ((URL, ((Bool) -> Void)?) -> Void)?) {
        self.currentTarget = currentTarget
        self.extensionContext = extensionContext
        self.openUrl = openUrl ?? { extensionContext?.open($0, completionHandler: $1) }
    }
}
