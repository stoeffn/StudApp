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

/// Localizable strings available for mock data.
public enum MockStrings {
    public enum Announcements: String, Localizable {
        case bringLaptops
    }

    public enum Courses: String, Localizable {
        case numericalAnalysis, numericalAnalysisSubtitle
        case linearAlgebraI, linearAlgebraII, linearAlgebraSubtitle
        case computerArchitecture
        case theoreticalComputerScience
        case dataScience
        case studAppFeedback
        case coding, codingSubtitle, codingSummary
        case operatingSystems
    }

    public enum Documents: String, Localizable {
        case organization, installingSwift, usingSwiftPlaygrounds, bigData, slides, exercise0, exercise1, exercise2, exercise3
    }

    public enum Folders: String, Localizable {
        case slides, exercises, solutions
    }

    public enum Events: String, Localizable {
        case forLoops, functionalProgramming, dataPreprocessing, group0
    }

    public enum Locations: String, Localizable {
        case bielefeldRoom, multimediaRoom, room135, basement, hugoKulkaRoom
    }

    public enum Semesters: String, Localizable {
        case winter1617, summer17, winter1718, summer18
    }

    public enum Users: String, Localizable {
        case theCount, theCountGivenName, theCountFamilyName
    }
}
