//
//  App.swift
//  StudKit
//
//  Created by Steffen Ryll on 28.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public enum App {
    // MARK: - Links

    public enum Links {
        // MARK: Website

        public static let website = URL(string: "https://www.studapp.eu/")

        public static let help = URL(string: "https://www.studapp.eu/help")

        public static let privacyPolicy = URL(string: "https://www.studapp.eu/privacy")

        public static let termsOfUse = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")

        // MARK: iTunes and App Store

        public static let appStore = URL(string: "https://itunes.apple.com/de/app/\(App.id)")

        public static let review = URL(string: "itms-apps://itunes.apple.com/de/app/\(App.id)?action=write-review")

        public static let manageSubscriptions
            = URL(string: "https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/manageSubscriptions")

        public static let store = URL(string: "studapp://")

        // MARK: Disclaimers

        public static let autorenewingSubscriptionDisclaimerUrl
            = URL(string: "studapp://disclaimers/auto-renewing-subscription")
    }

    // MARK: - Identifiers

    public static let id = "1317593772"

    static let groupIdentifier = "group.SteffenRyll.StudKit"

    static let iCloudContainerIdentifier = "iCloud.SteffenRyll.StudKit"

    // MARK: - Names

    public static let name = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String

    public static let versionName = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

    public static let authorName = "Steffen Ryll"

    // MARK: - Feedback

    public static let feedbackMailAddress = "studapp@stoeffn.de"

    // MARK: - Bundles

    static let kitBundle = Bundle(for: StudKitServiceProvider.self)
}
