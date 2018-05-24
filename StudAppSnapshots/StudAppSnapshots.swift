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

import XCTest

final class StudAppSnapshots: XCTestCase {
    // MARK: - Life Cycle

    override func setUp() {
        super.setUp()

        let app = XCUIApplication()
        app.setUpSnapshot()
        app.launchArguments += [Distributions.uiTestArgument]
        app.launch()
    }

    // MARK: - Courses

    func testCourses() {
        let app = XCUIApplication()

        if app.runsOniPad {
            XCUIDevice.shared.orientation = .landscapeLeft
        }

        app.buttons[MockStrings.Semesters.winter1718.localized(language: deviceLanguage)].tap()
        app.buttons[MockStrings.Semesters.summer18.localized(language: deviceLanguage)].tap()

        if app.runsOniPad {
            app.staticTexts[MockStrings.Courses.coding.localized(language: deviceLanguage)].tap()
        }

        snapshot("01-Courses")
    }

    func testCourse() {
        let app = XCUIApplication()
        guard !app.runsOniPad else { return }

        if app.runsOniPad {
            XCUIDevice.shared.orientation = .landscapeLeft
        }

        app.buttons[MockStrings.Semesters.summer18.localized(language: deviceLanguage)].tap()
        app.staticTexts[MockStrings.Courses.coding.localized(language: deviceLanguage)].tap()

        snapshot("02-Course")
    }

    // MARK: - Events

    func testEvents() {
        let app = XCUIApplication()

        if app.runsOniPad {
            XCUIDevice.shared.orientation = .landscapeLeft
        }

        app.buttons[Strings.Terms.events.localized(language: deviceLanguage)].tap()

        snapshot("03-Events")
    }

    // MARK: - Downloads

    func testDownloads() {
        let app = XCUIApplication()

        if app.runsOniPad {
            XCUIDevice.shared.orientation = .landscapeLeft
        }

        app.buttons[Strings.Terms.downloads.localized(language: deviceLanguage)].tap()

        snapshot("04-Downloads")
    }
}
