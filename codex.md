# Codex Notes: notetakingmvcuikit

This document captures the key details learned from reviewing the project.

## Overview

- Platform: iOS (Swift 5, UIKit, Storyboards)
- Persistence: Core Data (`NoteEntity`)
- Architecture: MVC with clear separation and an educational guide
- Design: Centralized design system (colors, typography, spacing, shadows, animations)
- Targets: App + Unit Tests + UI Tests
- External deps: None (no CocoaPods/SPM/Carthage detected)

## App Lifecycle & Entry

- `notetakingmvcuikit/AppDelegate.swift`: Standard app delegate. Delegates persistence saves to `CoreDataManager.shared` in `applicationWillTerminate`. A legacy `persistentContainer` is retained for reference but Model code uses `CoreDataManager`.
- `notetakingmvcuikit/SceneDelegate.swift`: Saves context on background (`sceneDidEnterBackground`).
- `notetakingmvcuikit/Info.plist`: Scene manifest points to `SceneDelegate` and main storyboard `Main`.
- Initial VC: `ViewController` (in `Main.storyboard`) shows a welcome screen. The "Get Started" button triggers `setupMVCArchitecture()` which embeds `NotesListViewController` in a `UINavigationController` and presents it full screen.

## Storyboards

- `notetakingmvcuikit/View/Base.lproj/Main.storyboard`
  - Scenes:
    - `ViewController` (initial)
    - `NotesListViewController` with storyboardIdentifier `NotesListViewController`
    - `NoteDetailViewController` with storyboardIdentifier `NoteDetailViewController`
  - `NotesListViewController` contains a table view with prototype cell reuseIdentifier `NoteCell` (subtitle style). Right bar button (+) is wired to `addButtonTapped:`.
  - `NoteDetailViewController` has `titleTextField` and `contentTextView`, nav bar Save/Cancel wired to `saveButtonTapped:` and `cancelButtonTapped:`.
- `notetakingmvcuikit/View/Base.lproj/LaunchScreen.storyboard`: Simple splash with icon and labels.

## Model Layer

- `notetakingmvcuikit/Model/notetakingmvcuikit.xcdatamodeld/.../contents`
  - Entity: `NoteEntity`
  - Attributes:
    - `id`: UUID (optional)
    - `title`: String (optional)
    - `content`: String (optional)
    - `category`: String (optional, default `General`)
    - `isFavorite`: Boolean (optional, default `NO`)
    - `colorHex`: String (optional, default `#4ECDC4`)
    - `createdAt`: Date (optional)
    - `updatedAt`: Date (optional)

- `notetakingmvcuikit/Model/CoreDataManager.swift`
  - Singleton Core Data wrapper (`shared`). Exposes `persistentContainer`, `context`, and `saveContext()`.
  - CRUD and helpers:
    - `createNote(title:content:category:) -> NoteEntity`
    - `getAllNotes() -> [NoteEntity]` (sorted by `updatedAt` desc)
    - `getNotes(byCategory:) -> [NoteEntity]`
    - `searchNotes(query:) -> [NoteEntity]` (title/content contains, case/diacritic-insensitive)
    - `getFavoriteNotes() -> [NoteEntity]`
    - `updateNote(_:title:content:category:) -> Bool`
    - `toggleFavorite(_:)`
    - `deleteNote(_:) -> Bool`
    - `deleteAllNotes()`
    - `getNoteStatistics() -> (total: Int, favorites: Int, categories: [String: Int])`
  - On first init, seeds sample notes (`setupSampleDataIfNeeded`) and assigns random pastel colors via `generateRandomNoteColor()`.

- `notetakingmvcuikit/Model/Note.swift`
  - Educational in-memory `Note` struct with an accompanying `NoteDataManager` (singleton) for CRUD. Currently not used by controllers (kept for teaching MVC without persistence).

## Controller Layer

- `notetakingmvcuikit/Controller/NotesController.swift`
  - Mediator between Views and Model, holds `CoreDataManager.shared` and a weak reference to a `NotesListViewProtocol` (`view`).
  - Responsibilities:
    - Fetch: `getAllNotes()`
    - Create: `createNote(title:content:category:)` with validation
    - Update: `updateNote(_:title:content:category:)` with validation
    - Delete: `deleteNote(_:)`
    - Search: `searchNotes(query:)`
    - Validation: `validateNoteData(title:content:)`
    - Navigation: `userWantsToCreateNote()`, `userSelectedNote(_:)`, `userWantsToDelete(note:)`, private `navigateToNoteDetail(note:isCreating:)` (pushes detail VC by storyboard ID)

- `notetakingmvcuikit/Controller/NotesListViewController.swift`
  - Displays notes list; owns table view and acts as data source + delegate.
  - Holds `var notesController: NotesController!` and sets `notesController.view = self`.
  - Loads notes via controller (`getAllNotes`) on `viewDidLoad` and `viewWillAppear`.
  - Add button triggers controller: `notesController.userWantsToCreateNote()`.
  - Implements `NotesListViewProtocol`:
    - `refreshNotesList()` -> reloads data from controller
    - `showError(message:)` -> presents alert
  - Applies `DesignSystem` styling (backgrounds, nav bar).

- `notetakingmvcuikit/Controller/NoteDetailViewController.swift`
  - Create/Edit screen: `titleTextField`, `contentTextView`.
  - Uses `notesController` to create/update on Save; pops with a short animation.
  - Populates fields when `noteToEdit` is provided; otherwise shows placeholder text.

- `notetakingmvcuikit/Controller/ViewController.swift`
  - Welcome screen. Styles UI using `DesignSystem` and animations.
  - `getStartedTapped(_:)` calls `setupMVCArchitecture()` which presents a nav controller with `NotesListViewController` as root.

## View Layer & Design System

- `notetakingmvcuikit/View/DesignSystem.swift`
  - Colors: primary variants, gradient start/end, system backgrounds, text colors, status colors, shadows.
  - Typography: app title, navigation, and content scales; note-specific fonts.
  - Spacing, CornerRadius, Shadow presets, Animation timings.
  - Extensions:
    - `UIView`: gradient backgrounds, card style, rounded corners, border, pulse/bounce/slide animations.
    - `UIButton`: primary style with press/release animations.
    - `UITextField`/`UITextView`: modern styling with padding/insets.
    - `UIColor`: hex init and `toHexString()`.

## Tests

- `notetakingmvcuikitTests`: Default XCTest template; no assertions yet.
- `notetakingmvcuikitUITests`: Launch and performance templates; no functional flows yet.

## Build Configuration

- Project: `notetakingmvcuikit.xcodeproj`
  - Uses Xcode’s File System Synchronized groups targeting the `notetakingmvcuikit` folder.
  - Bundle ID: `com.sachin.notetakingmvcuikit`
  - Marketing version 1.0; Current project version 1
  - iOS Deployment target: 18.5
  - Code signing: Automatic (team `QA7BM7NDFK`)

## Data & UX Flow (MVC)

1. User taps "Get Started" → `ViewController` presents `NotesListViewController` inside `UINavigationController`.
2. List screen loads notes via `NotesController.getAllNotes()` → `CoreDataManager.getAllNotes()`.
3. Add (+) → `NotesController.userWantsToCreateNote()` → pushes Detail view.
4. Save in Detail → `NotesController.createNote/updateNote` with validation → `CoreDataManager` CRUD → `view?.refreshNotesList()` triggers list reload.
5. Select a row → `NotesController.userSelectedNote` → pushes Detail to edit.
6. Swipe-to-delete → `NotesController.userWantsToDelete` → `CoreDataManager.deleteNote` → refresh list.

## Notable Behaviors & Observations

- The in-memory `Note` + `NoteDataManager` are educational; live app logic uses Core Data.
- `NotesController.view` is typed as `NotesListViewProtocol` and is set by the list screen. Errors are surfaced via that instance.
- IDs and timestamps are assigned in the Model layer; UI is kept “dumb”.
- Sample data is auto-seeded on first launch (empty store) with rich content and emoji.
- Color accents per note are set via random hex presets; cells render as stylized “cards”.

## Potential Improvements (Future Work)

- Present validation errors from the currently visible controller (e.g., detail) instead of via the list reference.
- Adopt `NSFetchedResultsController` to auto-reflect Core Data changes in the table view with animations.
- Add categories/tags UI, favorites filter, and search UI.
- Expand tests: unit test validation and Model CRUD; UI tests for create/edit/delete flows.
- Consider dependency injection for `CoreDataManager` to improve testability.
- Add accessibility labels and Dynamic Type support for better A11y.

## How to Run

1. Open `notetakingmvcuikit.xcodeproj` in Xcode 16+.
2. Select an iOS simulator (iOS 18.5) and run.
3. On the welcome screen, tap “Get Started” to open the notes list.

---

Generated by Codex after inspecting the repository structure and source files.

