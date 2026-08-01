# Habi

Habi is a UIKit habit tracking app for building daily routines, tracking progress, and staying consistent.

The project was built as a portfolio iOS app with a focus on clean UIKit architecture, local persistence, custom UI, and a polished MVP experience.

## Features

- Create, edit, archive, restore, and permanently delete habits
- Mark habits as completed for specific days
- Habit details screen with a paged monthly calendar
- Daily and weekly progress overview
- Statistics tab with weekly progress, monthly overview, top habits, and progress ring
- Profile screen with avatar, editable name, motivational quote, and personal progress summary
- Light, dark, and system theme preference
- English and Russian language preference
- Local data storage with Core Data

## Tech Stack

- UIKit
- SnapKit
- MVVM
- Dependency Injection
- Repository pattern
- Core Data
- Combine
- XCTest

## Architecture

The app follows MVVM with dependency injection:

- `ViewController` handles lifecycle, bindings, navigation, and user actions.
- `ViewModel` prepares screen state and contains screen logic.
- `UIView` subclasses are responsible for layout and rendering.
- `Repository` abstracts persistence and hides Core Data details from screens.
- `AppAssembly` and `AppDependencyContainer` create and inject dependencies.
- `Combine` is used to publish state changes from ViewModels to ViewControllers.

This keeps UIKit screens focused on presentation while persistence and business rules stay in separate layers.

## Persistence

Habi stores habits, habit records, profile data, theme, and language preferences locally with Core Data.

Current MVP data is local to the device. If the app is deleted, iOS removes the app container and the local database is deleted too.

## Tests

The project includes XCTest coverage for:

- habit statistics calculation
- habit calendar building

## Roadmap

- Firebase Auth and Firestore sync
- iCloud backup
- repository tests
- recurring reminders
- weekly habit frequency
- CI/Fastlane setup
- App Store screenshots

## Author

Built by Alice Kamyshenko as an iOS portfolio project.
