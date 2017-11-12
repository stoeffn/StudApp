//
//  Date+Formatting.swift
//  StudKit
//
//  Created by Steffen Ryll on 04.12.16.
//  Copyright © 2016 Julian Lobe & Steffen Ryll. All rights reserved.
//

extension Date {
    /// The amount of years from another date.
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// The amount of months from another date.
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// The amount of weeks from another date.
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfYear], from: date, to: self).weekOfYear ?? 0
    }
    /// The amount of days from another date.
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// The amount of hours from another date.
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// The amount of minutes from another date.
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// The amount of seconds from another date.
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
}

public extension Date {
    /// Returns a specific component of this date.
    func component(_ component: Calendar.Component) -> Int {
        return Calendar.current.component(component, from: self)
    }

    /// The first moment of a given Date, as a Date. If there were two midnights, it returns the first. If there was
    /// none, it returns the first moment that did exist.
    ///
    /// - returns: The first moment of the given date.
    var startOfDay: Date {
        return Calendar(identifier: .gregorian).startOfDay(for: self)
    }

    /// The first day of the date's month.
    var startOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: components) ?? self
    }

    /// Formatted date string using the current locale and the medium date style.
    var formattedDate: String {
        return DateFormatter.shared.mediumDate.string(from: self)
    }

    /// Formatted date string using the current locale and the medium date and time style.
    var formattedDateTime: String {
        return DateFormatter.shared.mediumDateTime.string(from: self)
    }

    /// Formatted date string using the current locale and the long date style.
    var formattedLongDate: String {
        return DateFormatter.shared.longDate.string(from: self)
    }

    /// Formatted as full month name followed by the year.
    var formattedMonthAndYear: String {
        return DateFormatter.shared.monthAndYear.string(from: self)
    }

    /// Formatted time string using the current locale and the short time style.
    var formattedTime: String {
        return DateFormatter.shared.shortTime.string(from: self)
    }

    /// The date's day of the week in short from, e.g. "Sun".
    var shortWeekday: String {
        return DateFormatter.shared.shortWeekday.string(from: self)
    }

    /// The date's day of the week in long from, e.g. "Sunday".
    var weekday: String {
        return DateFormatter.shared.weekday.string(from: self)
    }

    /// The difference from now in days as a relative date string.
    ///
    /// - returns: "yesterday", "today", and "tomorrow", the weekdays for the next week, or defaults to a long date
    var formattedAsRelativeDateFromNow: String {
        let today = Calendar(identifier: .gregorian).startOfDay(for: Date())
        let date = Calendar(identifier: .gregorian).startOfDay(for: self)
        return date.formatted(asRelativeDateFrom: today)
    }

    /// Returns the difference from another date in days as relative date string.
    ///
    /// - returns: "yesterday", "today", and "tomorrow", the weekdays for the next week, or defaults to a long date
    func formatted(asRelativeDateFrom date: Date) -> String {
        switch days(from: date) {
        case -1: return "yesterday"
        case 0: return "today"
        case 1: return "tomorrow"
        case 2...7: return weekday
        default: return formattedLongDate
        }
    }

    /// Returns the difference to now, formatted as a localized string that includes the remaining units w/o seconds.
    var formattedAsRemainingDateTimeFromNow: String? {
        return formatted(asRemainingDateTimeFrom: Date())
    }

    /// Returns the difference to `date`, formatted as a localized string that includes the remaining units w/o seconds.
    func formatted(asRemainingDateTimeFrom date: Date) -> String? {
        return DateComponentsFormatter.shared.dateTimeRemaining.string(from: date, to: self)
    }

    /// Returns the difference to now, formatted as a localized string that includes the remaining units w/o seconds.
    var formattedAsShortDifferenceFromNow: String? {
        return formatted(asShortDifferenceFrom: Date())
    }

    /// Returns the difference to `date`, formatted as a localized string that includes the units w/o seconds.
    func formatted(asShortDifferenceFrom date: Date) -> String? {
        return DateComponentsFormatter.shared.short.string(from: self, to: Date())
    }
}
