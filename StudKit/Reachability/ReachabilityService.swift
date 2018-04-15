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

import SystemConfiguration

/// Service that provides information on network reachability with the ability to watch for changes and post corresponding
/// notifications.
public final class ReachabilityService {
    private var reachability: SCNetworkReachability

    // MARK: - Life Cycle

    /// Creates a new reachability service for the host given.
    ///
    /// - Remark: In order to start watching for reachability changes, you must set `isActive` to `true`.
    init(host: String = "apple.com") {
        guard let reachability = SCNetworkReachabilityCreateWithName(nil, host) else {
            fatalError("Cannot create reachability service for host '\(host)' because `SCNetworkReachabilityCreateWithName` failed.")
        }
        self.reachability = reachability
        update()
    }

    deinit {
        deactivate()
    }

    // MARK: - Retrieving and Watching Reachability

    /// Current reachability flags.
    ///
    /// If `isActive` is set to `false`, these flags may not be up-to-date. You can manually update them by calling `update()`.
    public private(set) var currentFlags: SCNetworkReachabilityFlags = []

    /// Activates or deactivates automatically watching network reachability.
    ///
    /// Changes will be posted as `Notification.Name.reachabilityDidChange`.
    public var isActive: Bool = false {
        didSet {
            guard isActive != oldValue else { return }
            isActive ? activate() : deactivate()
        }
    }

    /// Manually updates the current reachability flags. May trigger a notification.
    public func update() {
        var flags = SCNetworkReachabilityFlags()
        SCNetworkReachabilityGetFlags(reachability, &flags)
        reachabilityChanged(flags: flags)
    }

    private func activate() {
        let selfReference = UnsafeMutableRawPointer(Unmanaged<ReachabilityService>.passUnretained(self).toOpaque())
        var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        context.info = selfReference

        let reachabilityCallback: SCNetworkReachabilityCallBack? = { _, flags, info in
            guard let info = info else { return }
            Unmanaged<ReachabilityService>.fromOpaque(info).takeUnretainedValue().reachabilityChanged(flags: flags)
        }

        if !SCNetworkReachabilitySetCallback(reachability, reachabilityCallback, &context) {
            fatalError("Cannot activate reachability service because `SCNetworkReachabilitySetCallback` failed.")
        }
        if !SCNetworkReachabilitySetDispatchQueue(reachability, .main) {
            fatalError("Cannot activate reachability service because `SCNetworkReachabilitySetDispatchQueue` failed.")
        }

        update()
    }

    private func deactivate() {
        SCNetworkReachabilitySetCallback(reachability, nil, nil)
        SCNetworkReachabilitySetDispatchQueue(reachability, nil)
    }

    private func reachabilityChanged(flags: SCNetworkReachabilityFlags) {
        guard currentFlags != flags else { return }
        currentFlags = flags

        NotificationCenter.default.post(name: .reachabilityDidChange, object: self, userInfo: [
            Notification.Name.reachabilityDidChangeFlagsKey: currentFlags,
        ])
    }
}

// MARK: - Notifications

extension Notification.Name {
    /// Invoked when network reachability changed. User info will contain the new reachability flags keyed by
    ///  `reachabilityChangedFlagsKey`.
    ///
    /// - Remark: You need to create and activate a `ReachabilityService` first in order to start receiving notifications.
    public static let reachabilityDidChange = Notification.Name(rawValue: "ReachabilityDidChange")

    /// User info key for `reachabilityChanged` flags.
    public static let reachabilityDidChangeFlagsKey = "flags"
}
