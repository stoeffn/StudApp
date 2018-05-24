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

import StudKit
import UIKit

public extension UIAlertController {
    public convenience init(confirmationWithAction actionTitle: String?, sourceView: UIView, sourceRect: CGRect? = nil,
                            handler: @escaping (UIAlertAction) -> Void) {
        self.init(title: nil, message: nil, preferredStyle: .actionSheet)
        addAction(UIAlertAction(title: Strings.Actions.cancel.localized, style: .cancel))
        addAction(UIAlertAction(title: actionTitle, style: .destructive, handler: handler))
        popoverPresentationController?.sourceView = sourceView
        popoverPresentationController?.sourceRect = sourceRect ?? sourceView.bounds
        popoverPresentationController?.permittedArrowDirections = [.up, .down]
    }
}
