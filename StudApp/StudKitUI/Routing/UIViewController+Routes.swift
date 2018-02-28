//
//  UIViewController+Routes.swift
//  StudKitUI
//
//  Created by Steffen Ryll on 11.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public extension UIViewController {
    public func performSegue(withRoute route: Routes) {
        performSegue(withIdentifier: route.segueIdentifier, sender: route)
    }

    public func prepareForRoute(using segue: UIStoryboardSegue, sender: Any?) {
        guard let route = sender as? Routes else { return }
        prepare(for: route, destination: segue.destination)
    }

    public func prepare(for route: Routes, destination: UIViewController) {
        if let controller = destination as? Routable {
            controller.prepareContent(for: route)
        } else if let navigationController = destination as? UINavigationController,
            let controller = navigationController.viewControllers.first as? Routable {
            controller.prepareContent(for: route)
        } else {
            let destinationDescription = String(describing: type(of: destination))
            let errorMessage = """
            Cannot use route with identifier '\(route.segueIdentifier)' with destination view controller
            '\(destinationDescription)' as neither it nor its first child view controller conform to protocol Routable'.
            """
            fatalError(errorMessage)
        }
    }
}
