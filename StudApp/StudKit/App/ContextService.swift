//
//  StudApp—Stud.IP to Go
//  Copyright © 2018, Steffen Ryll
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see http://www.gnu.org/licenses/.
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
