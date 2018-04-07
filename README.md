#  StudApp—Stud.IP to Go
StudApp is an _iOS_ application for the [Stud.IP learning platform](http://www.studip.de), which is used by more than half a million students and lecturers at over 40 _German_ universities and 30 other organizations like the _German Football Association_ or a state police. 

This project aims to take this platform to the next level by leveraging native capabilities of _iOS_. With _StudApp_, it easier than ever to browse your courses, documents, and announcements! Being officially certified by _Stud.IP e.V._, it provides excellent ways to stay up-to-date.

And—just like _Stud.IP_ itself—_StudApp_ is completely open source and free to be used by anyone as an [no-cost app on the App Store](https://itunes.apple.com/us/app/studapp/id1317593772?mt=8).

<img src="https://studapp.stoeffn.de/static/img/iPhone.png" alt="Screenshot: Course Overview" height="720" />

## Compatibility
Generally, _StudApp_ can be used with every _Stud.IP_ instance and most _iPhone_, _iPad_, and _iPod touch_ devices.

Please note that you need at least **Stud.IP 4.0** as well as **iOS 10.0**.

## Features

* Organizing courses (e.g. by selecting semesters or applying colors)
* Viewing general course information, announcements, events, and files
* Document download management with powerful search
* Complete offline availability
* Integrates with _iOS's_ native _Files_ app
* Integration into _Spotlight_ search and _Handoff_
* Usage of _3D Touch_, _Drag'n'Drop_, haptic feedback, and more
* Fully translated into _English_ and _German_
* Optimized for accessibility features like _Dynamic Type_ and _VoiceOver_

> See [my blog post](https://stoeffn.de/projects/studapp/) if you want to learn more about _StudApp_'s features and the motivations behind this project!

## Using StudApp
It is easy to get started!

### Students and Lecturers
Make sure your organizations supports _StudApp_ and [download it from the App Store](https://itunes.apple.com/us/app/studapp/id1317593772?mt=8)!

### Administrators
Do you want to add support for _StudApp_ at your university, school, club, or other kind of organization? Glad to hear that!

I've made it very easy for you:

1. Be administrator of a _Stud.IP_ instance of version 4 or higher
2. Activate the REST API
3. Generate _OAuth_ credentials
4. Give them to me in a secure way and I'll add your organization to _StudApp_ organization picker

…you can also shoot me a mail or open an issue!

> ##### Supporting StudApp at your organization doesn't cost a cent—how cool is that?
>
> If you want to support development, feel free to give a tip using the button in the in the app's about section. Thank you!

---

# Technical Stuff

## Setting Up a Development Environment

1. Download the most recent version of _Xcode_ from the _Mac App Store_
2. Run `xcode-select --install` in your shell in order to install headers for `CommonCrypto`
3. Run `brew install swiftlint` for installing an addtional Swift linting tool
4. Run `brew install swiftformat` for installing a _Swift_ source code formatting tool
5. Run `brew install carthage` for installing a simple, decentralized dependency manager for _Cocoa_
6. Run `carthage update` to checkout and compile dependencies
7. Open `StudApp/StudApp.xcodeproj`

## Trivia

* Data persistence is backed by _Core Data_
* Signing in uses _OAuth1_ for authorization and stores tokens securely in _Apple_'s _Keychain_
* Organizations are backed by _CloudKit_ and can be updated on the fly

## Architecture
If you want to know more about how _StudApp_ works, you've come to the right place! I'll give a general perspective on how things work.

> There are many topics that I've discussed in detail in other blog posts or will do so in the future. Give them a read if you like!
>
> You can also find more elaborate information as documentation comments in the source code. I encourage you to check it out!

### Patterns
This section gives a broad overview over design patterns used in _StudApp_ with the goal to make its code easy to understand and maintain.

#### Layout
_StudApp_ is divided into five distinct targets (and—where useful—accompanying testing targets):

**StudApp** is the actual iOS application with all view controllers and storyboards except those shared by multiple targets.

**StudKit** is a common framework containing all models, view models, and services. It is meant to be a common foundations for all targets, including potential _macOS_ apps.

**StudKitUI**, also a common framework, contains UI-related constants, views, and shared view controllers and storyboards.

**StudFileProvider** integrates with _Files_, which is _iOS_'s native file browser.

**StudFileProviderUI** displays user interfaces inside _Files_.

Each targets groups sources files logically instead of by type, sometimes nested. For instance, `Api`, `HttpMethods`, and `Result+Api` are all contained within one group. Extensions that operate on another framework's objects are grouped by framework.

#### MVVM
This project utilizes the [MVVM](https://de.wikipedia.org/wiki/Model_View_ViewModel) _"Model-View-ViewModel"_ pattern, which encourages separation of view and business logic and makes both easier to reuse and test. All models live in _StudKit_, e.g. in the form of database models and services. View models also reside in _StudKit_. Views and controllers form the View part of MVVM.

Using this approach as an addition to _Apple_'s _MVC_ actually makes a lot of sense for this project as I am able to reuse much of my view model logic in both the main app and the file provider. It also makes developing a potential _macOS_ app way easier.

#### Dependency Injection
Another pattern that _StudApp_ uses is [Dependency Injection](https://en.wikipedia.org/wiki/Dependency_injection), which makes unit testing a lot easier. For example, I swap the real API class with a mock subclass that always returns specific responses.

I've implement a minimal approach that lets targets register instances for specific types at launch. Later, services can resolve these instances at runtime.

### Frameworks and Libraries
To give you a broad overview, here are the frameworks and libraries used in _StudApp_:

#### First-Party
* `CloudKit`—Managing and updating organizations
* `CommonCrypto`—signing requests
* `CoreData`—persisting and organizing data
* `CoreGraphics`—drawing custom graphics like confetti or the loading indicator
* `CoreSpotlight`—indexing app content
* `FileProvider`—providing data to the _Files_ app
* `FileProviderUI`—showing UI in the _Files_ app
* `Foundation`—performing network requests and much more
* `MessageUI`—Showing a mail composer for feedback
* `MobileCoreServices`—dealing with file types
* `QuickLook`—previewing documents
* `SafariServices`—displaying websites inline and authorizing a user
* `StoreKit`—handling tipping
* `UIKit`—creating the _iOS_ app UI
* `WebKit`—rendering web-based content like announcements
* `XCTest`—testing my app

#### Third-Party
* [Swifter](https://github.com/httpswift/swifter)—Spinning up a simple redirect server needed when signing in

## Testing
Ensuring quality requires automated testing. I use _XCTest_ to unit-test my models with a focus on parsing API responses as well as updating and fetching data.

I've created a way to automatically load mock data into _Core Data_ when running UI tests. Those tests will be automated in the future.

## Code and Licensing
As mentioned in the introduction, _StudApp_ is completely open source and licensed under _GPL-3.0_. See [LICENSE.md](LICENSE.md) for details.

### Why I chose GPL
Since _StudApp_ is a complete software available on the _App Store_ and not a library, I want to encourage sharing improvements and prevent people from releasing their own closed source modified version since it took many months to build.

The thing about _GPL_ is that it requires source disclosure and forbids sublicencing, i.e. using something in a non-_GPL_-project. To that end, it is a perfect fit. Especially because _Stud.IP_ follows the same approach.

However, I appreciate feedback and contributions of any kind! It would also be great to find people excited about _Stud.IP_ who could help maintain this app in case I'm not able to.
