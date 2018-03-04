//
//  ContextService.swift
//  StudKit
//
//  Created by Steffen Ryll on 27.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

/// Provides information about the current application context.
public final class ContextService {
    public let currentTarget: Targets
    public let isRunningUiTests: Bool
    public let extensionContext: NSExtensionContext?
    public let openUrl: ((URL, ((Bool) -> Void)?) -> Void)?
    public let preferredContentSizeCategory: (() -> UIContentSizeCategory)

    init(currentTarget: Targets, isRunningUiTests: Bool, extensionContext: NSExtensionContext?,
         openUrl: ((URL, ((Bool) -> Void)?) -> Void)?, preferredContentSizeCategory: (() -> UIContentSizeCategory)?) {
        self.currentTarget = currentTarget
        self.isRunningUiTests = isRunningUiTests
        self.extensionContext = extensionContext
        self.openUrl = openUrl ?? { extensionContext?.open($0, completionHandler: $1) }
        self.preferredContentSizeCategory = preferredContentSizeCategory ?? { .unspecified }
    }

    public var prefersAccessibilityContentSize: Bool {
        guard #available(iOS 11.0, *) else {
            let accessibilityCategories: Set<UIContentSizeCategory> = [
                .accessibilityMedium, .accessibilityLarge, .accessibilityExtraLarge,
                .accessibilityExtraExtraLarge, .accessibilityExtraExtraExtraLarge,
            ]
            return accessibilityCategories.contains(preferredContentSizeCategory())
        }
        return preferredContentSizeCategory().isAccessibilityCategory
    }
}
