//
//  AGENTS.md.
//  HabitTracker
//
//  Created by Alice Kamyshenko on 15.05.2026.
//

# Habit Tracker iOS

## Stack
- UIKit
- SnapKit (partial usage)
- MVVM + DI
- Core Data
- Repository pattern via protocols
- SceneDelegate + Assembly startup
- No storyboard

## Architecture Rules
- No business logic in ViewController
- ViewModels contain screen logic
- Repository layer abstracts persistence
- Prefer programmatic UI
- Keep UI minimalistic
- Reuse existing components when possible

## Code Style
- Avoid force unwraps
- Prefer small extensions
- Prefer composition over inheritance
- Keep methods focused
- Follow existing project naming

## Already Implemented
- CoreDataService
- Habit / HabitRecord
- Repository layer
- HabitTrackerViewModel
- HabitTrackerViewController
- HabitCardView
- HabitCalendarView
- HabitCalendarDay
- HabitDayState
- Array+Chunked
- AddHabitViewController
- AddHabitView
- Emoji and color picker via UICollectionView
- Habit saving to Core Data
- toggleToday(for:)
- Mark habit completed for today

## Current Tasks
1. Swipe actions for delete/edit
2. Habit details screen:
   - expanded calendar
   - month paging
   - tap day to mark completed
   - edit title/color/emoji
3. Minimalistic UI improvements

## Planned Features
- Notifications/reminders
- User accounts
- Saved passwords
- Avatar upload
- User profile screen
- Statistics screen

## Future Improvements
- Add tests
- Active git workflow

## Expectations From Codex
- First analyze existing architecture
- Reuse existing patterns
- Before major changes explain the plan
- Keep consistency with current codebase

## Developer Context
The developer is still learning iOS development.

When suggesting changes:
- explain important architectural decisions
- prefer simple and maintainable solutions
- avoid overengineering
- briefly explain non-obvious code
- suggest best practices when relevant
- keep consistency more important than cleverness

## Teaching Mode
- When adding new patterns, explain why they are used
- Mention possible alternatives briefly
- Warn about common UIKit/CoreData mistakes
- Prefer readable code over advanced abstractions
