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

public extension Date {
    /// The amount of years from another date.
    public func years(since date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }

    /// The amount of months from another date.
    public func months(since date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }

    /// The amount of weeks from another date.
    public func weeks(since date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfYear], from: date, to: self).weekOfYear ?? 0
    }

    /// The amount of days from another date.
    public func days(since date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }

    /// The amount of hours from another date.
    public func hours(since date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }

    /// The amount of minutes from another date.
    public func minutes(since date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }

    /// The amount of seconds from another date.
    public func seconds(since date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
}

public extension Date {
    /// Returns a specific component of this date.
    public func component(_ component: Calendar.Component) -> Int {
        return Calendar.current.component(component, from: self)
    }

    /// The first moment of a given Date, as a Date. If there were two midnights, it returns the first. If there was
    /// none, it returns the first moment that did exist.
    ///
    /// - returns: The first moment of the given date.
    public var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    /// The first day of the date's month.
    public var startOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: components) ?? self
    }

    /// Returns whether this date is within the same day as another date.
    public func isInSameDay(as date: Date) -> Bool {
        return Calendar.current.isDate(self, inSameDayAs: date)
    }

    /// Returns this date as a formatted string using the formatter given.
    public func formatted(using formatter: DateFormatter) -> String {
        return formatter.string(from: self)
    }

    /// Returns the difference to now, formatted as a localized string that includes the remaining units w/o seconds.
    public var formattedAsRemainingDateTimeFromNow: String? {
        return formatted(asRemainingDateTimeFrom: Date())
    }

    /// Returns the difference to `date`, formatted as a localized string that includes the remaining units w/o seconds.
    public func formatted(asRemainingDateTimeFrom date: Date) -> String? {
        return DateComponentsFormatter.dateTimeRemaining.string(from: date, to: self)
    }

    /// Returns the difference to now, formatted as a localized string that includes the remaining units w/o seconds.
    public var formattedAsShortDifferenceFromNow: String? {
        return formatted(asShortDifferenceFrom: Date())
    }

    /// Returns the difference to `date`, formatted as a localized string that includes the units w/o seconds.
    public func formatted(asShortDifferenceFrom date: Date) -> String? {
        guard let differenceString = DateComponentsFormatter.short.string(from: self, to: date) else { return nil }
        let localizedString = "%@ ago".localized(differenceString)
        let fixedLocalizedString = try? localizedString.replacingMatches(for: "(?<=Jahre)|(?<=Monate)|(?<=Tage)", with: "n")
        return fixedLocalizedString ?? localizedString
    }

    /// The difference from now in days as a relative date string.
    ///
    /// - returns: "yesterday", "today", and "tomorrow", the weekdays for the next week, or defaults to a long date
    public var formattedAsRelativeDateFromNow: String {
        return startOfDay.formatted(asRelativeDateFrom: Date().startOfDay)
    }

    /// Returns the difference from another date in days as relative date string.
    ///
    /// - returns: "yesterday", "today", and "tomorrow", the weekdays for the next week, or defaults to a long date
    public func formatted(asRelativeDateFrom date: Date) -> String {
        switch days(since: date) {
        case -1: return "Yesterday".localized
        case 0: return "Today".localized
        case 1: return "Tomorrow".localized
        case 2 ... 7: return formatted(using: .weekday)
        default: return formatted(using: .longDate)
        }
    }
}
