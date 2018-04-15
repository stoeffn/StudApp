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

/// Compilation targets associated with `StudApp`.
///
/// You can use this this enumeration to identify and distinguish between the main app, any extensions, and testing.
///
/// - Remark: Please note that frameworks are not explicitly listed and there is no differentiation betweeen test targets.
public enum Targets: String {
    case app, fileProvider, fileProviderUI, tests

    /// All targets that are embedded in the _iOS_ app.
    public static let iOSTargets: [Targets] = [.app, .fileProvider]

    /// Current target as initialized at app, app extension, or test start.
    public static var current: Targets {
        return currentContext.currentTarget
    }
}

// MARK: - Context

extension Targets {
    public struct Context {
        let currentTarget: Targets
        let extensionContext: NSExtensionContext?
        let openUrl: ((URL, [String: Any], ((Bool) -> Void)?) -> Void)?
        let preferredContentSizeCategory: (() -> UIContentSizeCategory)?

        public init(currentTarget: Targets, extensionContext: NSExtensionContext? = nil,
                    openUrl: ((URL, [String: Any], ((Bool) -> Void)?) -> Void)? = nil,
                    preferredContentSizeCategory: (() -> UIContentSizeCategory)? = nil) {
            self.currentTarget = currentTarget
            self.extensionContext = extensionContext
            self.openUrl = openUrl
            self.preferredContentSizeCategory = preferredContentSizeCategory
        }
    }

    static var currentContext = Context(currentTarget: .app)
}

// MARK: - Properties

public extension Targets {
    var extensionContext: NSExtensionContext? {
        guard self == Targets.current else { return nil }
        return Targets.currentContext.extensionContext
    }

    var preferredContentSizeCategory: UIContentSizeCategory {
        guard self == Targets.current else { return .unspecified }
        return Targets.currentContext.preferredContentSizeCategory?() ?? .unspecified
    }

    var prefersAccessibilityContentSize: Bool {
        guard #available(iOS 11.0, *) else {
            return [
                .accessibilityMedium, .accessibilityLarge, .accessibilityExtraLarge,
                .accessibilityExtraExtraLarge, .accessibilityExtraExtraExtraLarge,
            ].contains(preferredContentSizeCategory)
        }
        return preferredContentSizeCategory.isAccessibilityCategory
    }
}

// MARK: - Communicating with Other Processes

public extension Targets {
    func open(url: URL, completion: ((Bool) -> Void)?) {
        guard self == Targets.current else {
            completion?(false)
            return
        }

        if let openUrl = Targets.currentContext.openUrl {
            return openUrl(url, [:], completion)
        }
        if let openUrl = Targets.currentContext.extensionContext?.open {
            return openUrl(url, completion)
        }
        completion?(false)
    }
}
