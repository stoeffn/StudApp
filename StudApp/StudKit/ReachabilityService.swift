//
//  ReachabilityService.swift
//  StudKit
//
//  Created by Steffen Ryll on 23.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import SystemConfiguration

/// Service that provides information on network reachability with the ability to watch for changes and post corresponding
/// notifications.
public final class ReachabilityService {
    private var reachability: SCNetworkReachability

    // MARK: - Life Cycle

    /// Creates a new reachability service. In order to start watching for reachability changes, you must set `isActive` to
    /// `true`.
    init() {
        guard let reachability = SCNetworkReachabilityCreateWithName(nil, "apple.com") else {
            fatalError("Cannot create reachability service because `SCNetworkReachabilityCreateWithName` failed.")
        }
        self.reachability = reachability
    }

    deinit {
        deactivate()
    }

    // MARK: - Retrieving and Watching Reachability

    /// Current reachability flag.
    ///
    /// If `isActive` is set to `false`, these flags may not be up-to-date. You can manually update them by calling `update()`.
    public private(set) var currentReachabilityFlags: SCNetworkReachabilityFlags = []

    /// Activates or deactivates automatically watching network reachability.
    ///
    /// Changes will be posted as `Notification.Name.reachabilityChanged`.
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
        if !SCNetworkReachabilitySetDispatchQueue(reachability, DispatchQueue.main) {
            fatalError("Cannot activate reachability service because `SCNetworkReachabilitySetDispatchQueue` failed.")
        }

        update()
    }

    private func deactivate() {
        SCNetworkReachabilitySetCallback(reachability, nil, nil)
        SCNetworkReachabilitySetDispatchQueue(reachability, nil)
    }

    private func reachabilityChanged(flags: SCNetworkReachabilityFlags) {
        guard currentReachabilityFlags != flags else { return }
        currentReachabilityFlags = flags

        NotificationCenter.default.post(name: .reachabilityChanged, object: self, userInfo: [
            Notification.Name.reachabilityChangedFlagsKey: currentReachabilityFlags,
        ])
    }
}

// MARK: - Notifications

extension Notification.Name {
    /// Invoked when network reachability changed. User info will contain the new reachability flags keyed by
    ///  `reachabilityChangedFlagsKey`.
    ///
    /// - Remark: You need to create and activate a `ReachabilityService` first in order to start receiving notifications.
    public static let reachabilityChanged = Notification.Name(rawValue: "ReachabilityChanged")

    /// User info key for `reachabilityChanged` flags.
    public static let reachabilityChangedFlagsKey = "flags"
}
