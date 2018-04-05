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

import QuickLook
import StudKit

public enum Routes {
    case about

    case announcement(Announcement)

    case colorPicker(sender: Any?, completion: (ColorPickerViewModel<UIColor>.Row) -> Void)

    case confetti(alert: UIAlertController)

    case course(Course)

    case courseList(for: User?)

    case disclaimer(with: String)

    case downloadList(for: User?)

    case emptyCourse

    case eventList(for: Course)

    case folder(File)

    case preview(for: File, QLPreviewControllerDelegate?)

    case semesterList(for: User)

    case settings

    case signIn

    case signIntoOrganization(Organization)

    case store

    case unwindToApp

    case unwindToAppAndSignOut

    case unwindToSignIn

    case verification

    private var destinationStoryboard: UIStoryboard? {
        switch self {
        case .signIn:
            return UIStoryboard(name: "SignIn", bundle: App.kitBundle)
        case .emptyCourse:
            return UIStoryboard(name: "Courses", bundle: nil)
        case .verification:
            return UIStoryboard(name: "Verification", bundle: App.kitBundle)
        default:
            return nil
        }
    }

    private var destinationIdentifier: String? {
        switch self {
        case .emptyCourse: return "EmptyCourseController"
        case .signIn: return "SignInNavigationController"
        case .verification: return "VerificationNavigationController"
        default: return nil
        }
    }

    public var segueIdentifier: String {
        switch self {
        case .about: return "about"
        case .announcement: return "announcement"
        case .colorPicker: return "colorPicker"
        case .confetti: return "confetti"
        case .course: return "course"
        case .courseList: return "courseList"
        case .disclaimer: return "disclaimer"
        case .downloadList: return "downloadList"
        case .emptyCourse: return "emptyCourse"
        case .eventList: return "eventList"
        case .folder: return "folder"
        case .preview: return "preview"
        case .semesterList: return "semesterList"
        case .settings: return "settings"
        case .signIn: return "signIn"
        case .signIntoOrganization: return "signIntoOrganization"
        case .store: return "store"
        case .unwindToApp: return "unwindToApp"
        case .unwindToAppAndSignOut: return "unwindToAppAndSignOut"
        case .unwindToSignIn: return "unwindToSignIn"
        case .verification: return "verification"
        }
    }

    public func instantiateViewController() -> UIViewController {
        guard let storyboard = destinationStoryboard else {
            fatalError("Cannot instantiate storyboard for route with identifier '\(segueIdentifier)'.")
        }
        guard let destinationIdentifier = destinationIdentifier else {
            fatalError("Route with identifier '\(segueIdentifier)' has no destination view controller identifier.")
        }
        return storyboard.instantiateViewController(withIdentifier: destinationIdentifier)
    }
}
