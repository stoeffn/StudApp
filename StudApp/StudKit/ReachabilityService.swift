//
//  ReachabilityService.swift
//  StudKit
//
//  Created by Steffen Ryll on 23.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import SystemConfiguration

public class ReachabilityService: ByTypeNameIdentifiable {
    public private(set) var currentReachabilityFlags: SCNetworkReachabilityFlags = []

    private var reachability: SCNetworkReachability

    init() {
        guard let reachability = SCNetworkReachabilityCreateWithName(nil, "apple.com") else {
            fatalError("Cannot create reachability service because `SCNetworkReachabilityCreateWithName` failed.")
        }
        self.reachability = reachability
    }

    deinit {
        deactivate()
    }

    public var isActive: Bool = false {
        didSet {
            guard isActive != oldValue else { return }
            isActive ? activate() : deactivate()
        }
    }

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

        currentReachabilityFlags = []
    }

    private func reachabilityChanged(flags: SCNetworkReachabilityFlags) {
        guard currentReachabilityFlags != flags else { return }
        currentReachabilityFlags = flags

        NotificationCenter.default.post(name: .reachabilityChanged, object: currentReachabilityFlags)
    }
}

extension Notification.Name {
    public static let reachabilityChanged = Notification.Name(rawValue: "ReachabilityChanged")
}
