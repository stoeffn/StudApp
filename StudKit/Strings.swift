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

/// Localizable strings available to _StudApp_.
public enum Strings {
    /// Actions a user can perform.
    ///
    /// - Remark: Use title-case.
    public enum Actions: String, Localizable {
        case addOrganization
        case allowNotifications
        case chooseColor
        case configureInSettings
        case dismiss
        case hide, show
        case leaveTip
        case markAsNew, markAsSeen
        case okay, cancel
        case openInSafari
        case rateStudApp
        case remove
        case removeAllDownloads
        case retry, reload
        case sendFeedback
        case share
        case showHiddenCourses
        case signOut
    }

    /// Callouts and larger bodies of text.
    public enum Callouts: String, Localizable {
        case downloadsSizeDisclaimer
        case feedbackDisclaimer, feedbackTitle
        case noAnnouncements
        case noCourse, noCourseSubtitle
        case noDocuments
        case noDownloads, noDownloadsSubtitle
        case noEvents, noEventsSubtitle
        case noFiles, noFilesSubtitle
        case noMoreEvents, noMoreEventsSubtitle
        case notifications
        case openSourceDisclaimer
        case organizationsSubtitle
        case noSemesters, noSemestersSubtitle
        case noUpcomingEvents
        case rateManually
        case signedInAsAt
        case studAppDisclaimer
        case supportersDisclaimer
        case tipLater
        case tippingDisclaimer
        case thankYou
        case thankYouForTipping
        case thanksTo
        case welcomeToStudApp
    }

    /// Colors available for selection.
    ///
    /// - Remark: Use title-case.
    public enum Colors: String, Localizable {
        case yellow, red, orange, lightOrange, green, lightGreen, lightBlue, blue, purple
    }

    /// Day titles.
    ///
    /// - Remark: Use title-case.
    public enum Days: String, Localizable {
        case yesterday, today, tomorrow
    }

    /// Available errors.
    ///
    /// - Remark: Use title-case.
    public enum Errors: String, Localizable {
        case downloadingDocument
        case generic
        case `internal`
        case internetConnection
        case launchingAppStore
        case organizationAuthorization
        case organizationUnsupported
        case organizationsUpdate
        case userActivityRestoration
    }

    /// Generic formats.
    public enum Formats: String, Localizable {
        /// Example "at room 404"
        case atLocation

        /// Example: "by Steve Jobs"
        case byEntity

        /// Example: "from April 2018 to September 2018"
        case fromTo

        /// Example: "hosted by icloud.com"
        case hostedBy

        /// Example: "modified by Jony Ive"
        case modifiedBy

        /// Example: "Next Event: Tomorrow"
        case nextEventAt

        /// Example "one item"
        case numberOfItems

        /// Example: "11x" (eleven times)
        case numberOfTimes

        /// Example: "April – May"
        case range

        /// Example "two months ago"
        case timeAgo
    }

    /// Generic states.
    ///
    /// - Remark: Use title-case.
    public enum States: String, Localizable {
        case bookmarked
        case canceled
        case collapsed, expanded
        case current
        case hidden, visible
        case new, modified
        case notDownloaded, downloading, downloaded
        case notLoaded
        case unavailable
    }

    /// Generic terms.
    ///
    /// - Remark: Use title-case.
    public enum Terms: String, Localizable {
        case about
        case announcements
        case color
        case course, courses, courseNumber
        case document, documents
        case downloads
        case events, allEvents
        case folder
        case gitHub
        case help
        case location
        case more
        case notifications
        case organizations
        case privacyPolicy
        case semesters
        case settings
        case studIP
        case summary
        case termsOfUse
        case website
    }
}
