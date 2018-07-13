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

// MARK: - Keys

extension UserDefaults {
    private enum Keys: String {
        case areNotificationsEnabled, deviceToken, didRequestRatingAt, showsHiddenCourses, userId
    }
}

// MARK: - Settings

public extension UserDefaults {
    public static var studKit: UserDefaults {
        return ServiceContainer.default[StorageService.self].defaults
    }

    @objc public dynamic var areNotificationsEnabled: Bool {
        get { return bool(forKey: Keys.areNotificationsEnabled.rawValue) }
        set { set(newValue, forKey: Keys.areNotificationsEnabled.rawValue) }
    }

    @objc public dynamic var deviceToken: Data? {
        get { return object(forKey: Keys.deviceToken.rawValue) as? Data }
        set { set(newValue, forKey: Keys.deviceToken.rawValue) }
    }

    @objc public dynamic var didRequestRatingAt: Date? {
        get { return object(forKey: Keys.didRequestRatingAt.rawValue) as? Date }
        set { set(newValue, forKey: Keys.didRequestRatingAt.rawValue) }
    }

    @objc public dynamic var showsHiddenCourses: Bool {
        get { return bool(forKey: Keys.showsHiddenCourses.rawValue) }
        set { set(newValue, forKey: Keys.showsHiddenCourses.rawValue) }
    }

    @objc public dynamic var userId: String? {
        get { return string(forKey: Keys.userId.rawValue) }
        set { set(newValue, forKey: Keys.userId.rawValue) }
    }
}
