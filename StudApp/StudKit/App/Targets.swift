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
        return ServiceContainer.default[ContextService.self].currentTarget
    }
}
