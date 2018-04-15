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

import Foundation

/// Possible ways to distribute an application.
public enum Distributions {
    case debug, uiTest, testFlight, appStore

    private static var isDebug: Bool = {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }()

    private static var isUiTest = ProcessInfo.processInfo.arguments.contains(uiTestArgument)

    private static let isTestFlight = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"

    /// When launching UI tests, add this process launch argument. Otherwise, the application will not be able to properly its
    /// distribution.
    ///
    /// ## Example
    /// ```
    /// let app = XCUIApplication()
    /// app.launchArguments += [Distributions.uiTestArgument]
    /// ```
    public static let uiTestArgument = "uiTest"

    /// How this binary was distributed.
    public static var current: Distributions = {
        switch (isDebug, isUiTest, isTestFlight) {
        case (true, false, _): return Distributions.debug
        case (_, true, _): return Distributions.uiTest
        case (_, _, true): return Distributions.testFlight
        default: return Distributions.appStore
        }
    }()
}

// MARK: - Describing

extension Distributions: CustomStringConvertible {
    public var description: String {
        switch self {
        case .debug: return "Debug"
        case .uiTest: return "UI Test"
        case .testFlight: return "TestFlight"
        case .appStore: return "App Store"
        }
    }
}
