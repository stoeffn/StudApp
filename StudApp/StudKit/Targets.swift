//
//  Targets.swift
//  StudKit
//
//  Created by Steffen Ryll on 17.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public enum Targets: String {
    case app, fileProvider, fileProviderUI, tests

    public static let iOSTargets: [Targets] = [.app, .fileProvider]
}
