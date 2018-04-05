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

/// Provides constants regarding app information.
public enum App {

    // MARK: - Urls

    public enum Urls {

        // MARK: Website

        public static let website = URL(string: "https://studapp.stoeffn.de/")!

        public static let help = URL(string: "https://studapp.stoeffn.de/help")!

        public static let privacyPolicy = URL(string: "https://studapp.stoeffn.de/privacy")!

        public static let termsOfUse = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!

        // MARK: iTunes and App Store

        /// App Store URL.
        public static let appStore = URL(string: "https://itunes.apple.com/de/app/\(App.id)")!

        /// URL of the app's App Store review page.
        public static let review = URL(string: "itms-apps://itunes.apple.com/de/app/\(App.id)?action=write-review")!

        // MARK: Callbacks

        /// URL that is opened in response to a successful authorization.
        public static let signInCallback = URL(string: "http://127.0.0.1:8080/sign-in")!
    }

    // MARK: - Identifiers

    /// Apple App Id as used by the App Store.
    static let id = "1317593772"

    /// Application group identifier used for sharing data between targets.
    static let groupIdentifier = "group.SteffenRyll.StudKit"

    /// Application iCloud container identifier.
    static let iCloudContainerIdentifier = "iCloud.SteffenRyll.StudKit"

    // MARK: - Names

    /// Display name of the application.
    public static let name = Bundle.main.infoDictionary!["CFBundleDisplayName"] as! String

    /// Human-readable version name for this application.
    public static let versionName = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String

    /// The application's author.
    public static let authorName = "Steffen Ryll"

    // MARK: - Feedback

    /// Email address to send app feedback to.
    public static let feedbackMailAddress = "studapp@stoeffn.de"

    /// URL scheme registered with this application.
    public static let scheme = "studapp"

    // MARK: - Bundles

    /// Bundle of the `StudKit` framework.
    public static let kitBundle = Bundle(for: StudKitServiceProvider.self)
}
