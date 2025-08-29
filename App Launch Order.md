# App Launch Order

This document outlines the order in which files/functions run when launching and navigating through the app.

## App Startup (Cold Launch)

1) Process start
- `@main` in `AppDelegate` creates the application delegate instance.

2) AppDelegate launch
- `AppDelegate.application(_:didFinishLaunchingWithOptions:)`
  - First app logic entry point.

3) Scene configuration
- `AppDelegate.application(_:configurationForConnecting:options:)`
  - Returns the scene config named "Default Configuration".

4) Scene connection
- `SceneDelegate.scene(_:willConnectTo:options:)`
  - With `UISceneStoryboardFile` = `Main` in Info.plist, iOS loads `Main.storyboard` automatically and attaches a window.

5) Initial storyboard VC lifecycle
- `ViewController.viewDidLoad()`
- `ViewController.viewWillAppear(_:)`
- `ViewController.viewDidAppear(_:)`

6) Foreground/active callbacks
- `SceneDelegate.sceneDidBecomeActive(_:)`

## From Welcome → Notes List

7) User taps Get Started
- `ViewController.getStartedTapped(_:)`
  - Calls `setupMVCArchitecture()`
  - Instantiates `NotesListViewController` (storyboard identifier: `NotesListViewController`)
  - Embeds in `UINavigationController` and presents full screen

8) Notes list lifecycle and setup
- `NotesListViewController.viewDidLoad()`
  - `setupView()` (styling)
  - `setupController()`
    - Creates `NotesController()`
      - `NotesController.init()` prints initialization log
      - Accesses `CoreDataManager.shared` (first touch initializes Core Data stack)
        - `CoreDataManager.init()` → `setupSampleDataIfNeeded()`
          - Calls `getAllNotes()` (triggers lazy `persistentContainer.loadPersistentStores`) → prints success
          - Seeds sample notes if store is empty
  - `loadNotes()` → `notesController.getAllNotes()` → `CoreDataManager.getAllNotes()` → reload table
- Usual lifecycle continues: `viewWillAppear(_:)` → `viewDidAppear(_:)`

## Interactions in Notes List

9) Create a note
- Tap + (bar button)
  - `NotesListViewController.addButtonTapped(_:)` → `NotesController.userWantsToCreateNote()`
  - `NotesController` pushes `NoteDetailViewController` via storyboard id `NoteDetailViewController`

10) Edit a note
- Select a row
  - `tableView(_:didSelectRowAt:)` → `NotesController.userSelectedNote(_:)`
  - Controller pushes `NoteDetailViewController` with selected note

11) Delete a note
- Swipe to delete
  - `tableView(_:commit:forRowAt:)` → `NotesController.userWantsToDelete(note:)`
  - `CoreDataManager.deleteNote(_:)` → view refresh via protocol method

## Note Detail Flow

12) Detail screen lifecycle
- `NoteDetailViewController.viewDidLoad()`
  - `setupView()` (styling)
  - `setupController()` (ensures a controller instance exists)
  - `populateFields()` (existing note or placeholder for new)

13) Save / Cancel
- Save: `saveButtonTapped(_:)`
  - New: `NotesController.createNote(title:content:)`
  - Edit: `NotesController.updateNote(_:title:content:)`
  - On success: controller calls `view?.refreshNotesList()`; detail pops
- Cancel: `cancelButtonTapped(_:)` pops without saving

## Backgrounding & Termination

14) App goes to background
- `SceneDelegate.sceneDidEnterBackground(_:)`
  - Calls `(UIApplication.shared.delegate as? AppDelegate)?.saveContext()` → `CoreDataManager.shared.saveContext()`

15) App terminates
- `AppDelegate.applicationWillTerminate(_:)`
  - Calls `CoreDataManager.shared.saveContext()`

---

This sequence reflects the project’s current code paths, storyboard configuration, and Core Data initialization behavior.

![App Launch Flow Diagram](app_launch_order_diagram.svg)

## Related Files

- Assets.xcassets: Asset catalog for images, app icon, and colors. It does not execute code; UIKit loads assets by name at render time.

- Info.plist: Launch configuration read by iOS at startup. In this app it sets:
  - `UISceneStoryboardFile = Main` (loads `Main.storyboard`)
  - `UISceneDelegateClassName = $(PRODUCT_MODULE_NAME).SceneDelegate`
  - `UILaunchStoryboardName = LaunchScreen`

- MVC_Architecture_Guide.swift: Educational/documentation source with comments and examples. Not part of the execution path; safe to exclude from build if desired.

- SceneDelegate.swift: Scene lifecycle host invoked during launch and app state changes:
  - `scene(_:willConnectTo:options:)` loads the main storyboard window
  - `sceneDidBecomeActive(_:)`, `sceneWillResignActive(_:)`, `sceneWillEnterForeground(_:)`, `sceneDidEnterBackground(_:)`
  - In this project, backgrounding triggers a Core Data save via AppDelegate.
