#  StudApp—Stud.IP on the Go

StudApp is an iOS application for the [Stud.IP](http://www.studip.de/) learning platform, which is widely used by German Universities and other organizations as it enables course organization and file management with ease. This project aims to take it to the next level by providing deep system integration by leveraging native capabilities of iOS.

## Compability

* Requires at least Stud.IP 4
* Requires iOS 10.0 at minimum (some features require iOS 11)
* Optimized for iPhone and iPad

# Features

* Organizing courses (e.g. by selecting semesters or applying colors)
* Viewing general course information, announcements, events, and files
* Document download management with powerful search
* Complete offline availability
* Integrates with iOS's native Files app
* Integration into Spotlight search and Handoff
* Usage of 3D Touch, Drag'n'Drop, Haptic feedvack, and more
* Fully translated into English and German

_TODO: Describe each feature in detail and provide screenshots_

---

# Technical Trivia

* Backed by Core Data
* Uses OAuth for authorization (and stores tokens securely in Apple's Keychain)
* Organizations are backed by CloudKit and can be updated on the fly

# Setting Up a Development Environment

1. Download the most recent version of Xcode from the Mac App Store
2. Run `xcode-select --install` in your shell in order to install headers for `CommonCrypto`
3. Run `brew install swiftlint` for installing an addtional Swift linting tool
4. Run `brew install swiftformat` for installing a Swift source code formatting tool
5. Open `StudApp/StudApp.xcodeproj`

# Project Architecture

## Pattern

This project utilizes the [MVVM](TODO) _"Model-View-ViewModel"_ pattern, which leads to separation of view and business logic and makes both easier to reuse and test. Models can be found in _StudKit_, e.g. in the form of database models and services. View models also reside in _StudKit_. Views and controllers form the View part of MVVM.

## Dependency Injection

## Layout

StudApp is divided into three distinct targets (and accompanying testing targets), namely _StudApp_, _StudKit_, and _StudFileProvider_.

**StudApp** is the actual iOS application with all view controllers and storyboards except those shared by multiple targets.

**StudKit** is a common framework containing all models, view models, and services. It is meant to be a common foundations for all targets, including potential macOS apps.

**StudKitUI** contains UI-related constants and views as well as shared view controllers and storyboards.

**StudFileProvider** integrates with "Files", which is iOS's native file browser.

**StudFileProviderUI** displays user interfaces inside "Files".

## Documentation

# License

