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

/// Possible user activities that can be used e.g. for _Handoff_.
///
/// - Remark: The raw values are the activities' identifiers. They should follow reverse-DNS format by convention. Be
///           sure to declare the same values in `Info.plist`.
public enum UserActivities: String {
    case course = "SteffenRyll.StudKit.Course"

    case document = "SteffenRyll.StudKit.Document"
}

// MARK: - Creating a User Activity

public extension NSUserActivity {
    /// Initializes and returns the object using the specified type.
    convenience init(type: UserActivities) {
        self.init(activityType: type.rawValue)
    }
}
