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

/// Manages applications main view.
public final class AppViewModel {
    private let coreDataService = ServiceContainer.default[CoreDataService.self]
    private let studIpService = ServiceContainer.default[StudIpService.self]

    public init() {}

    /// Whether the user is currently signed in.
    public var isSignedIn: Bool {
        return studIpService.isSignedIn
    }

    public func signOut() {
        studIpService.signOut()
    }

    public func update(forced: Bool = false, completion: (() -> Void)? = nil) {
        guard let user = User.current, !ProcessInfo.processInfo.isLowPowerModeEnabled else { return }

        coreDataService.performBackgroundTask { context in
            self.studIpService.updateMainData(organization: user.organization.in(context), forced: forced) { _ in completion?() }
        }
    }
}
