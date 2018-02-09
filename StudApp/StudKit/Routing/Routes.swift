//
//  Routes.swift
//  StudKit
//
//  Created by Steffen Ryll on 06.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import QuickLook

public enum Routes {
    case about(handler: () -> Void)

    case settings(handler: (SettingsResult) -> Void)

    case signIn(handler: (Result<Void>) -> Void)

    case signIntoOrganization(OrganizationRecord, handler: (Result<Void>) -> Void)

    case preview(File, QLPreviewControllerDelegate?)

    case course(Course)

    case emptyCourse

    case announcement(Announcement, handler: () -> Void)

    case folder(File)

    case colorPicker(sender: Any?, handler: (Int, UIColor) -> Void)

    private var destinationStoryboard: UIStoryboard? {
        switch self {
        case .signIn:
            return UIStoryboard(name: "SignIn", bundle: App.kitBundle)
        case .emptyCourse:
            return UIStoryboard(name: "Courses", bundle: nil)
        default:
            return nil
        }
    }

    private var destinationIdentifier: String? {
        switch self {
        case .signIn: return "SignInNavigationController"
        case .emptyCourse: return "EmptyCourseController"
        default: return nil
        }
    }

    public var segueIdentifier: String {
        switch self {
        case .about: return "about"
        case .settings: return "settings"
        case .signIn: return "signIn"
        case .signIntoOrganization: return "signIntoOrganization"
        case .preview: return "preview"
        case .course: return "course"
        case .emptyCourse: return "emptyCourse"
        case .announcement: return "announcement"
        case .folder: return "folder"
        case .colorPicker: return "colorPicker"
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

public enum SettingsResult {
    case none, signedOut
}
