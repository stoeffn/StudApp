//
//  MainViewModel.swift
//  StudKit
//
//  Created by Steffen Ryll on 10.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public final class MainViewModel {
    private let studIp = ServiceContainer.default[StudIpService.self]

    public init() { }

    public var isSignedIn: Bool {
        return studIp.isSignedIn
    }
}
