//
//  UIViewController+Routes.swift
//  StudKit
//
//  Created by Steffen Ryll on 11.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public extension UIViewController {
    public func performSegue(withRoute route: Routes) {
        performSegue(withIdentifier: route.identifier, sender: route)
    }

    public func prepare(for route: Routes, destination: UIViewController) {
        if let controller = destination as? Routable {
            controller.prepareDependencies(for: route)
        } else if let navigationController = destination as? UINavigationController,
            let controller = navigationController.viewControllers.first as? Routable {
            controller.prepareDependencies(for: route)
        } else {
            let destinationDescription = String(describing: type(of: self))
            let errorMessage = """
            Cannot use route with identifier '\(route.identifier)' with destination view controller
            '\(destinationDescription)' as neither it nor its first child view controller conform to protocol Routable'.
            """
            fatalError(errorMessage)
        }
    }
}
