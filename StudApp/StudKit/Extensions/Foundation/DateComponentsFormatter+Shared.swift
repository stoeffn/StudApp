//
//  DateComponentsFormatter+Shared.swift
//  StudKit
//
//  Created by Steffen Ryll on 12.12.16.
//  Copyright © 2016 Julian Lobe & Steffen Ryll. All rights reserved.
//

/// A container for a lazy date components formatter cache.
struct SharedDateComponentsFormatters {
    lazy var dateTimeRemaining: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 2
        formatter.includesApproximationPhrase = true
        formatter.includesTimeRemainingPhrase = true
        formatter.allowedUnits = [.year, .month, .weekOfMonth, .day, .hour, .minute]
        return formatter
    }()

    lazy var short: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1
        formatter.collapsesLargestUnit = true
        return formatter
    }()
}

extension DateComponentsFormatter {
    static var shared = SharedDateComponentsFormatters()
}
