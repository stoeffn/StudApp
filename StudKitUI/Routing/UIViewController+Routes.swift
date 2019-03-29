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

public extension UIViewController {
    func performSegue(withRoute route: Routes) {
        performSegue(withIdentifier: route.segueIdentifier, sender: route)
    }

    func prepareForRoute(using segue: UIStoryboardSegue, sender: Any?) {
        guard let route = sender as? Routes else { return }
        prepare(for: route, destination: segue.destination)
    }

    func prepare(for route: Routes, destination: UIViewController) {
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
