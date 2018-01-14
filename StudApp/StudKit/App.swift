//
//  App.swift
//  StudKit
//
//  Created by Steffen Ryll on 28.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

/// Provides constants regarding app information.
public enum App {
    /// Display name of the application.
    public static let name = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String

    /// Human-readable version name for this application.
    public static let versionName = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

    /// The application's author.
    public static let authorName = "Steffen Ryll"

    /// App Store URL.
    public static let url = URL(string: "https://itunes.apple.com/de/app/\(App.id)")

    /// URL of the app's App Store review page.
    public static let reviewUrl = URL(string: "itms-apps://itunes.apple.com/de/app/\(App.id)?action=write-review")

    /// Email address to send app feedback to.
    public static let feedbackMailAddress = "studapp@stoeffn.de"

    /// URL scheme registered with this application.
    public static let scheme = "studapp"

    /// URL that is opened in response to a successful authorization.
    ///
    /// This URL automatically redirects to `studapp://sign-in` including all query parameters. Unfortunately, this redirection
    /// is neccessary because Stud.IP does not support custom schemes.
    public static let signInCallbackUrl = URL(string: "https://studapp.stoeffn.de/sign-in")

    /// Apple App Id as used by the App Store.
    static let id = "1317593772"

    /// Bundle of the `StudKit` framework.
    static let kitBundle = Bundle(for: StudKitServiceProvider.self)

    /// Application group identifier used for sharing data between targets.
    static let groupIdentifier = "group.SteffenRyll.StudKit"

    /// Application iCloud container identifier.
    static let iCloudContainerIdentifier = "iCloud.SteffenRyll.StudKit"
}
