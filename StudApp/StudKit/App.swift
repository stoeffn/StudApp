//
//  App.swift
//  StudKit
//
//  Created by Steffen Ryll on 28.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public enum App {
    public static let id = "1317593772"

    public static let name = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String

    public static let versionName = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

    public static let authorName = "Steffen Ryll"

    public static let url = URL(string: "https://itunes.apple.com/de/app/\(App.id)")

    public static let reviewUrl = URL(string: "itms-apps://itunes.apple.com/de/app/\(App.id)?action=write-review")

    public static let feedbackMailAddress = "studapp@stoeffn.de"

    public static let manageSubscriptionsUrl = URL(string:
        "https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/manageSubscriptions")

    static let kitBundle = Bundle(for: StudKitServiceProvider.self)

    static let groupIdentifier = "group.SteffenRyll.StudKit"

    static let iCloudContainerIdentifier = "iCloud.SteffenRyll.StudKit"
}
