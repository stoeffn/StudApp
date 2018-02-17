//
//  Date+Formatting.swift
//  StudKit
//
//  Created by Steffen Ryll on 04.12.16.
//  Copyright © 2016 Steffen Ryll. All rights reserved.
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
        return Calendar(identifier: .gregorian).startOfDay(for: self)
    }

    /// The first day of the date's month.
    public var startOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: components) ?? self
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
        return "%@ ago".localized(differenceString)
    }

    /// The difference from now in days as a relative date string.
    ///
    /// - returns: "yesterday", "today", and "tomorrow", the weekdays for the next week, or defaults to a long date
    public var formattedAsRelativeDateFromNow: String {
        let today = Calendar(identifier: .gregorian).startOfDay(for: Date())
        let date = Calendar(identifier: .gregorian).startOfDay(for: self)
        return date.formatted(asRelativeDateFrom: today)
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
