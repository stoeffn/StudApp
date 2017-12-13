//
//  Routes.swift
//  StudKit
//
//  Created by Steffen Ryll on 06.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public enum Routes {
    case empty

    case about

    case signIn

    case store

    case signIntoOrganization(OrganizationRecord)

    case preview(File)

    case course(Course)

    case folder(File)

    case colorPicker(sender: Any?, (Int, UIColor) -> Void)

    private var destinationStoryboard: UIStoryboard? {
        switch self {
        case .signIn:
            return UIStoryboard(name: "SignIn", bundle: App.kitBundle)
        default:
            return nil
        }
    }

    private var destinationIdentifier: String? {
        switch self {
        case .signIn: return "SignInNavigationController"
        default: return nil
        }
    }

    public var segueIdentifier: String {
        switch self {
        case .empty: return "empty"
        case .about: return "about"
        case .signIn: return "signIn"
        case .store: return "store"
        case .signIntoOrganization: return "signIntoOrganization"
        case .preview: return "preview"
        case .course: return "course"
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
