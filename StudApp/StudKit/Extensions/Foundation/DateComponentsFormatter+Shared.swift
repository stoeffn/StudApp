//
//  DateComponentsFormatter+Shared.swift
//  StudKit
//
//  Created by Steffen Ryll on 12.12.16.
//  Copyright © 2016 Steffen Ryll. All rights reserved.
//

extension DateComponentsFormatter {
    public static let dateTimeRemaining: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 2
        formatter.includesApproximationPhrase = true
        formatter.includesTimeRemainingPhrase = true
        formatter.allowedUnits = [.year, .month, .weekOfMonth, .day, .hour, .minute]
        return formatter
    }()

    public static let short: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1
        formatter.collapsesLargestUnit = true
        return formatter
    }()
}
