//
//  NotesController.swift
//  notetakingmvcuikit
//
//  CONTROLLER LAYER - MVC Architecture
//
//  The CONTROLLER is the coordinator/mediator between MODEL and VIEW:
//  - Receives user actions from VIEW
//  - Processes business logic and validation
//  - Interacts with MODEL to get/modify data
//  - Updates VIEW with new data or state changes
//  - Handles navigation between different views
//
//  Key MVC Principle: Controller acts as the "traffic controller"
//  It knows about both Model and View, but Model and View don't know about each other
//

import UIKit
import CoreData

// MARK: - Notes Controller
// This class implements the CONTROLLER in MVC architecture
// It coordinates all interactions between the Model (Note data) and Views (UI)
class NotesController {
    
    // MARK: - Model Reference  
    // Controller has direct access to the Model layer (now using Core Data)
    private let coreDataManager = CoreDataManager.shared
    
    // MARK: - View References
    // Controller maintains weak references to Views to avoid retain cycles
    weak var view: NotesListViewProtocol?
    
    // MARK: - Initialization
    init() {
        // Controller can initialize with any required setup
        print("📱 NotesController initialized - MVC pattern in action!")
    }
    
    // MARK: - Data Operations (CONTROLLER coordinates MODEL access)
    
    /// Gets all notes from Model and prepares them for View
    /// This is a perfect example of Controller mediating between Model and View
    func getAllNotes() -> [NoteEntity] {
        // CONTROLLER asks MODEL for data (now from Core Data)
        let notes = coreDataManager.getAllNotes()
        
        // CONTROLLER could perform additional processing here if needed
        // For example: filtering, sorting, formatting, etc.
        print("📊 Controller retrieved \(notes.count) notes from Core Data Model")
        
        return notes
    }
    
    /// Creates a new note through Model
    /// Demonstrates how CONTROLLER handles business logic and coordinates updates
    func createNote(title: String, content: String, category: String = "General") {
        // CONTROLLER performs validation (business logic)
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || 
              !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            // CONTROLLER tells VIEW to show error
            view?.showError(message: "Note must have either a title or content")
            return
        }
        
        // CONTROLLER asks MODEL to create the note (now using Core Data)
        let newNote = coreDataManager.createNote(title: title, content: content, category: category)
        print("✅ Controller created new note: '\(newNote.title ?? "Untitled")'")
        
        // CONTROLLER tells VIEW to refresh
        view?.refreshNotesList()
    }
    
    /// Updates an existing note
    /// Shows how CONTROLLER coordinates complex operations  
    func updateNote(_ note: NoteEntity, title: String, content: String, category: String? = nil) {
        // CONTROLLER performs validation
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || 
              !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            view?.showError(message: "Note must have either a title or content")
            return
        }
        
        // CONTROLLER asks MODEL to update (now using Core Data)
        let success = coreDataManager.updateNote(note, title: title, content: content, category: category)
        
        if success {
            print("✏️ Controller updated note: '\(note.title ?? "Untitled")'")
            // CONTROLLER tells VIEW to refresh
            view?.refreshNotesList()
        } else {
            print("❌ Controller failed to update note")
            // CONTROLLER tells VIEW to show error
            view?.showError(message: "Failed to update note")
        }
    }
    
    /// Deletes a note  
    /// Demonstrates CONTROLLER handling user actions
    func deleteNote(_ note: NoteEntity) {
        // CONTROLLER asks MODEL to delete (now using Core Data)
        let success = coreDataManager.deleteNote(note)
        
        if success {
            print("🗑️ Controller deleted note: '\(note.title ?? "Untitled")'")
            // CONTROLLER tells VIEW to refresh
            view?.refreshNotesList()
        } else {
            print("❌ Controller failed to delete note")
            // CONTROLLER tells VIEW to show error
            view?.showError(message: "Failed to delete note")
        }
    }
    
    // MARK: - User Action Handlers (CONTROLLER responds to VIEW events)
    
    /// Handles user wanting to create a new note
    /// Shows how CONTROLLER manages navigation and view coordination
    func userWantsToCreateNote() {
        print("👤 User wants to create a new note")
        
        // CONTROLLER handles navigation logic
        // In a more complex app, this might involve presenting a modal or pushing a new view
        navigateToNoteDetail(note: nil, isCreating: true)
    }
    
    /// Handles user selecting a note to view/edit
    func userSelectedNote(_ note: NoteEntity) {
        print("👤 User selected note: '\(note.title ?? "Untitled")'")
        
        // CONTROLLER handles navigation to detail view
        navigateToNoteDetail(note: note, isCreating: false)
    }
    
    /// Handles user wanting to delete a note
    func userWantsToDelete(note: NoteEntity) {
        print("👤 User wants to delete note: '\(note.title ?? "Untitled")'")
        
        // CONTROLLER could show confirmation dialog here
        // For simplicity, we'll delete immediately
        deleteNote(note)
    }
    
    // MARK: - Navigation Logic (CONTROLLER responsibility)
    
    /// Handles navigation to note detail view
    /// This shows how CONTROLLER manages app flow
    private func navigateToNoteDetail(note: NoteEntity?, isCreating: Bool) {
        // In a real app, CONTROLLER would coordinate with navigation
        // For this example, we'll use the current view controller to present the detail
        
        guard let viewController = view as? NotesListViewController else {
            print("❌ Controller: Cannot navigate - view reference is invalid")
            return
        }
        
        // Create detail view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Try to get the detail view controller from storyboard
        if let detailVC = storyboard.instantiateViewController(withIdentifier: "NoteDetailViewController") as? NoteDetailViewController {
            // CONTROLLER configures the new view
            detailVC.notesController = self
            detailVC.noteToEdit = note
            detailVC.isCreatingNew = isCreating
            
            // CONTROLLER handles navigation
            viewController.navigationController?.pushViewController(detailVC, animated: true)
        } else {
            // Fallback: create programmatically
            let detailVC = NoteDetailViewController()
            detailVC.notesController = self
            detailVC.noteToEdit = note
            detailVC.isCreatingNew = isCreating
            
            viewController.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    // MARK: - Business Logic Examples (CONTROLLER responsibility)
    
    /// Example of business logic that CONTROLLER might handle
    func searchNotes(query: String) -> [NoteEntity] {
        // CONTROLLER gets data from MODEL (now using Core Data search)
        let filteredNotes = coreDataManager.searchNotes(query: query)
        
        print("🔍 Controller searched notes: \(filteredNotes.count) matches for '\(query)'")
        return filteredNotes
    }
    
    /// Example of data validation (CONTROLLER responsibility)
    func validateNoteData(title: String, content: String) -> (isValid: Bool, errorMessage: String?) {
        // CONTROLLER implements business rules
        
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Rule 1: Must have either title or content
        if trimmedTitle.isEmpty && trimmedContent.isEmpty {
            return (false, "Note must have either a title or content")
        }
        
        // Rule 2: Title length limit
        if trimmedTitle.count > 100 {
            return (false, "Title must be 100 characters or less")
        }
        
        // Rule 3: Content length limit
        if trimmedContent.count > 10000 {
            return (false, "Content must be 10,000 characters or less")
        }
        
        return (true, nil)
    }
}

// MARK: - MVC Communication Examples
/*
 
 This section demonstrates the proper MVC communication flow:
 
 1. USER INTERACTION:
    User taps "Add Note" button in VIEW (NotesListViewController)
    
 2. VIEW TO CONTROLLER:
    VIEW calls: notesController.userWantsToCreateNote()
    
 3. CONTROLLER LOGIC:
    Controller processes the request and decides what to do
    
 4. CONTROLLER TO VIEW:
    Controller navigates to detail view or shows error
    
 5. CONTROLLER TO MODEL:
    If user saves, Controller calls: dataManager.createNote()
    
 6. MODEL UPDATES:
    Model updates its data structure
    
 7. CONTROLLER TO VIEW:
    Controller tells View to refresh: view?.refreshNotesList()
    
 8. VIEW UPDATES:
    View reloads its display with new data from Controller
 
 KEY PRINCIPLES DEMONSTRATED:
 - Model never talks directly to View
 - View never talks directly to Model
 - All communication goes through Controller
 - Each layer has single responsibility
 - Controller coordinates everything
 
 */