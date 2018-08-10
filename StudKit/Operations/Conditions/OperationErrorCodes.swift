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

enum OperationErrorCodes: Int {
    case conditionFailed = 1
    case executionFailed = 2

    static let domain = "OperationErrors"

    static func == (lhs: Int, rhs: OperationErrorCodes) -> Bool {
        return lhs == rhs.rawValue
    }

    static func == (lhs: OperationErrorCodes, rhs: Int) -> Bool {
        return lhs.rawValue == rhs
    }
}

extension NSError {
    convenience init(code: OperationErrorCodes, userInfo: [String: Any]? = nil) {
        self.init(domain: OperationErrorCodes.domain, code: code.rawValue, userInfo: userInfo)
    }
}
